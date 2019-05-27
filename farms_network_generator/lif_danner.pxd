"""Leaky Integrate and Fire Neuron Based on Danner et.al."""

from farms_dae_generator.parameters cimport Param
from farms_network_generator.neuron cimport Neuron

cdef struct DannerNeuronInput:
    unsigned int neuron_idx
    unsigned int weight_idx

cdef class LIFDanner(Neuron):
    cdef:
        readonly str n_id

        unsigned int num_inputs

        #: parameters
        #: constants
        double c_m
        double g_leak
        double e_leak
        double tau_noise
        double v_max
        double v_thr
        double g_syn_e
        double g_syn_i
        double e_syn_e
        double e_syn_i
        double m_e
        double m_i
        double b_e
        double b_i

        #: states
        Param v

        #: inputs
        Param alpha

        #: ode
        Param vdot

        #: Ouputs
        Param nout

        #: neuron connenctions
        DannerNeuronInput[:] neuron_inputs

    cdef:
        void c_ode_rhs(self, double[:] _y, double[:] _p) nogil
        void c_output(self) nogil
        double c_neuron_inputs_eval(self, double _neuron_out, double _weight) nogil
