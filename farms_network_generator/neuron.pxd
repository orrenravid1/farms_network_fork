""" Header for Neuron Base Class. """

cdef class Neuron(object):
    """Base neuron class.
    """

    cdef:
        str model_type

    cdef:
        void c_ode_rhs(self, double[:] _y, double[:] _p) nogil
        void c_output(self) nogil
