
// Basic Data Types
// Home-study problem.
// Duration 60 minutes
 
// Please return the solution via email within an hour of receipt of this request arriving in your email box.  
 
// Please implement this in one of C or C++.
 
// The following are not good answers:
// 1. copied solutions from the internet/textbook 
// 2. simply call STL functions 
 
// Exercise to Do: 
// Implement an object that has methods called ‘Push’ and ‘Pop’. 
// This object should be able to handle having integer values
// passed to Push and should be able to return integer value from Pop in stack order
// (i.e. Last in First out - LIFO).
 
// Now implement an object or extend the previous object to implement methods
// called ‘Queue’ and ‘Dequeue’. This object should also be able to handle integer values
// passed to Queue and should be able to return integer values from Dequeue in queue order
// (i.e. First In, First Out - FIFO).
 
#include <cassert>
#include <cmath>
#include <iostream>
using namespace std;

class MyLifo {
    public:
        MyLifo(unsigned int size)
            : _size(size), _index(0), _stack(new int[size])
        {
        }

        ~MyLifo()
        {
            delete _stack;
        }

        // returns 1 if success, 0 if cannot push anymore values onto LIFO
        int Push(int value)
        {
            int resp = 0;
            if( _index >= 0 && _index <= _size-1 ) {
                _stack[_index] = value;
                _index++;
                resp = 1;
            }
            return resp;
        }

        // returns 1 if success, 0 if nothing in LIFO
        int Pop(int &value)
        {
            int resp = 0;
            if( _index > 0 && _index <= _size ) {
                _index--;
                value = _stack[_index];
                resp = 1;
            }
            return resp;
        }

    private:
        const unsigned int _size;
        unsigned int _index;
        int * const _stack;

};

class MyFifo {
public:
    MyFifo(unsigned int size)
        : _size(size), _curr(0), _next(1), _count(0), _stack(new int[size])
    {
    }

    ~MyFifo()
    {
        delete _stack;
    }

    // returns 1 if success, 0 if cannot push anymore values onto FIFO
    int Queue(int value)
    {
        int resp = 0;
        if( _count < _size ) {
            if( _next > 0 )
                _stack[_next-1] = value;
            else
                _stack[_size-1] = value;
            _next++;
            _count++;
            if( _next >= _size ) {
                _next = 0;
            }
            resp = 1;
        }
        return resp;
    }

    // returns 1 if success, 0 if nothing left in FIFO
    int Dequeue(int &value)
    {
        int resp = 0;
        if( _count > 0 && _count <= _size ) {
            value = _stack[_curr];
            _curr++;
            _count--;
            if( _curr >= _size ) {
                _curr = 0;
            }
            resp = 1;
        }
        return resp;
    }


private:
    const unsigned int _size;
    unsigned int _curr, _next;
    unsigned int _count;
    int * const _stack;

};

int main() {
    MyFifo my_fifo(3);
    MyLifo my_lifo(3);

    assert( my_lifo.Push(3) == 1 );
    assert( my_lifo.Push(5) == 1 );
    assert( my_lifo.Push(7) == 1 );
    assert( my_lifo.Push(1) == 0 );

    int value = 0;
    assert( my_lifo.Pop(value) == 1);
    assert( value == 7 );
    assert( my_lifo.Pop(value) == 1 );
    assert( value == 5 );
    assert( my_lifo.Pop(value) == 1 );
    assert( value == 3 );
    assert( my_lifo.Pop(value) == 0 );
    assert( value == 3 );

    assert( my_fifo.Queue(2) == 1 );
    assert( my_fifo.Queue(4) == 1 );
    assert( my_fifo.Queue(6) == 1 );
    assert( my_fifo.Queue(8) == 0 );

    assert( my_fifo.Dequeue(value) == 1 );
    assert( value == 2 );
    assert( my_fifo.Dequeue(value) == 1 );
    assert( value == 4 );
    assert( my_fifo.Dequeue(value) == 1 );
    assert( value == 6 );
    assert( my_fifo.Dequeue(value) == 0 );
    assert( value == 6 );

    return 0;
}