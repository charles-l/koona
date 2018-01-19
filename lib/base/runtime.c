#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define DEBUG

// we can store 512 objects on our GC's heap
#define HEAP_SIZE 5

// maximum of 32 locals in a scope
#define MAX_LOCALS 32

// this struct doesn't fit on a cacheline, so its not really performant
// it's just easier to visualize as a struct
//
// in real life, it would make more sense to byte
// align information and tag the lower few bytes

enum ktype {
    STRING_T,
    BOOL_T,
    NUM_T
};

typedef struct {
    // tag use for our heap
    unsigned short used : 1;

    // tag used for GC
    unsigned short mark : 1;

    // size of the object
    unsigned short size : 14;

    // TODO: do static type checking instead of dynamic checking
    enum ktype type;
    char *data;
} kobj_t;

struct kstack_frame_t {
    size_t n;
    // TODO: just count the number of locals ahead of time and reference a local array that stores them
    kobj_t *cells[MAX_LOCALS]; // more wasted space to avoid mallocing/freeing stack frames
    struct kstack_frame_t *prev, *next;
};

typedef struct kstack_frame_t kstack_frame_t;

kstack_frame_t koona_stack_root = {0, {}, NULL, NULL};

static kobj_t gc_heap[HEAP_SIZE];

unsigned khalloc();
void khfree(kobj_t *);

void dump_obj(kobj_t *t) {
    switch(t->type) {
        case NUM_T:
            fprintf(stderr, "%d", *((int *) t->data));
            break;
        case BOOL_T:
            fprintf(stderr, *((_Bool *) t->data) ? "true" : "false");
            break;
        case STRING_T:
            fprintf(stderr, "%s", t->data);
            break;
    }
}

void dump_objn(kobj_t *t) {
    dump_obj(t);
    fprintf(stderr, "\n");
}

kstack_frame_t make_call_frame(kstack_frame_t *caller, kobj_t *args, ...) {
    va_list ap;
    va_start(ap, args);
    kobj_t *o;
    int i = 0;
    kstack_frame_t f = {0, {}, caller, NULL};
    f.cells[i++] = args;
    while((o = va_arg(ap, kobj_t *)) != NULL) {
        f.cells[i++] = o;
    }
    f.n = i;
    va_end(ap);
    return f;
}

void mark(kobj_t *f) {
    if(f->mark)
        return;
#ifdef DEBUG
    fprintf(stderr, "MARKING OBJECT: ");
    dump_objn(f);
#endif
    // mark any children objects in here
    f->mark = 1;
}

void do_gc() {
    // clear out previous marks
    for(unsigned i = 0; i < HEAP_SIZE; i++) {
        gc_heap[i].mark = 0;
    }

    for(kstack_frame_t *f = &koona_stack_root; f != NULL; f = f->next) {
        for(unsigned i = 0; i < f->n; i++) {
            mark(f->cells[i]);
        }
    }

    for(unsigned i = 0; i < HEAP_SIZE; i++) {
        if(!gc_heap[i].mark) {
#ifdef DEBUG
            fprintf(stderr, "DELETING OBJECT heap[%u]: ", i);
            dump_objn(&gc_heap[i]);
#endif
            // free it
            khfree(&gc_heap[i]);
        }
    }
}

// mark and sweep gc reference:
// http://journal.stuffwithstuff.com/2013/12/08/babys-first-garbage-collector/
//
// this is totally overkill since we can't have cirular references
// so we could just do reference counting
unsigned khalloc() {
    for(unsigned i = 0; i < HEAP_SIZE; i++) {
        if(!gc_heap[i].used) {
#ifdef DEBUG
            fprintf(stderr, "heap[%u] is free\n", i);
#endif
            return i;
        }
    }

#ifdef DEBUG
    fprintf(stderr, "=== GARBAGE COLLECTING ===\n");
#endif

    do_gc();

    return khalloc();
}

// free an object on the heap
void khfree(kobj_t *o) {
    free(o->data);
    o->used = 0;
}

// helper function for filling in struct the struct
// and inserting it on the GC heap
kobj_t *new_obj() {
    kobj_t obj;
    obj.used = 1;
    obj.mark = 0;
    obj.size = 0;
    obj.data = NULL;
    obj.type = BOOL_T;
    unsigned i = khalloc();
    gc_heap[i] = obj;
    return gc_heap + i;
}

kobj_t *make_string(char *s) {
    kobj_t *obj = new_obj();
    size_t l = strlen(s);
    obj->size = l;
    obj->type = STRING_T;
    obj->data = strdup(s);
    return obj;
}

kobj_t *make_int(int i) {
    kobj_t *obj = new_obj();
    obj->size = sizeof(int);
    obj->type = NUM_T;
    obj->data = malloc(sizeof(int));
    memcpy(obj->data, &i, sizeof(int));
    return obj;
}

kobj_t *make_bool(_Bool b) {
    kobj_t *obj = new_obj();
    obj->size = sizeof(_Bool);
    obj->type = BOOL_T;
    // yes - i realize how ridiculous this is
    // i'm allocating a byte of memory to store a bool
    // and referencing it with a pointer. The friggin'
    // pointer is larger than the data i'm storing itself
    //
    // it would be better to just pack this information into the pointer itself
    // but i've already given up on performance

    obj->data = malloc(sizeof(_Bool));
    memcpy(obj->data, &b, sizeof(_Bool));
    return obj;
}

int unbox_int(kobj_t *o) {
    return *((int *) o->data);
}

_Bool unbox_bool(kobj_t *o) {
    return *((_Bool *) o->data);
}

char *unbox_string(kobj_t *o) {
    return o->data;
}

void ensure_type(kobj_t *a, kobj_t *b, enum ktype t) {
    if(a->type != t || b->type != t) {
        fprintf(stderr, "RUNTIME ERROR: types are incorrect");
        exit(1);
    }
}

kobj_t *_op_do_add(kobj_t *a, kobj_t *b) {
    ensure_type(a, b, NUM_T);
    return make_int(unbox_int(a) + unbox_int(b));
}

kobj_t *_op_do_sub(kobj_t *a, kobj_t *b) {
    ensure_type(a, b, NUM_T);
    return make_int(unbox_int(a) - unbox_int(b));
}

kobj_t *_op_do_mul(kobj_t *a, kobj_t *b) {
    ensure_type(a, b, NUM_T);
    return make_int(unbox_int(a) * unbox_int(b));
}

kobj_t *_op_do_div(kobj_t *a, kobj_t *b) {
    ensure_type(a, b, NUM_T);
    if(*(b->data) == 0) {
        fprintf(stderr, "RUNTIME ERROR: divide by zero");
        exit(1);
    }
    return make_int(unbox_int(a) / unbox_int(b));
}
