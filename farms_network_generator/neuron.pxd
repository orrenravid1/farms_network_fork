""" Header for Neuron Base Class. """

cdef class Neuron(object):
    """Base neuron class.
    """

    cdef:
        str _model_type

    cdef:
        void c_ode_rhs(self, double[:] _y, double[:] _p)
        void c_output(self)
