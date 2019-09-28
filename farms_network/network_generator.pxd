from farms_network.leaky_integrator cimport LeakyIntegrator
from farms_dae.parameters cimport Parameters
from farms_network.neuron cimport Neuron


cdef class NetworkGenerator(object):
    cdef:
        dict __dict__
        Neuron[:] c_neurons
        Parameters x
        Parameters xdot
        Parameters c
        Parameters u
        Parameters p
        Parameters y

        unsigned int num_neurons
    cdef:
        # void c_step(self, double[:] inputs)
        double[:] c_ode(self, double t, double[:] state)
