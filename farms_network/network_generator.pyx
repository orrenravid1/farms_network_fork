"""
-----------------------------------------------------------------------
Copyright 2018-2020 Jonathan Arreguit, Shravan Tata Ramalingasetty
Copyright 2018 BioRobotics Laboratory, École polytechnique fédérale de Lausanne

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-----------------------------------------------------------------------

Generate neural network.
"""
from farms_container.table cimport Table
from libc.stdio cimport printf

from farms_network.neuron cimport Neuron

from collections import OrderedDict

import farms_pylog as pylog
import numpy as np
from cython.parallel import prange

from farms_network.neuron_factory import NeuronFactory

cimport cython
cimport numpy as cnp


cdef class NetworkGenerator:
    """ Generate Neural Network.
    """

    def __init__(self, graph, neural_container):
        """Initialize.

        Parameters
        ----------
        graph_file_path: <str>
            File path to the graphml structure.
        """
        super(NetworkGenerator, self).__init__()

        #: Attributes
        self.neurons = OrderedDict()  #: Neurons in the network
        self.states = <Table > neural_container.add_table('states')
        self.dstates = <Table > neural_container.add_table('dstates')
        self.constants = <Table > neural_container.add_table('constants', table_type='CONSTANT')
        self.inputs = <Table > neural_container.add_table('inputs')
        self.weights = <Table > neural_container.add_table('weights', table_type='CONSTANT')
        self.parameters = <Table > neural_container.add_table('parameters', table_type='CONSTANT')
        self.outputs = <Table > neural_container.add_table('outputs')

        self.odes = []

        self.fin = {}
        self.integrator = {}

        #:  Read the graph
        self.graph = graph

        #: Get the number of neurons in the model
        self.num_neurons = len(self.graph)

        self.c_neurons = np.ndarray((self.num_neurons,), dtype=Neuron)
        self.generate_neurons(neural_container)
        self.generate_network(neural_container)

    def generate_neurons(self, neural_container):
        """Generate the complete neural network.
        Instatiate a neuron model for each node in the graph

        Returns
        -------
        out : <bool>
            Return true if successfully created the neurons
        """
        cdef int j
        for j, (name, neuron) in enumerate(sorted(self.graph.nodes.items())):
            #: Add neuron to list
            pylog.debug(
                'Generating neuron model : {} of type {}'.format(
                    name, neuron['model']))
            #: Generate Neuron Models
            _neuron = NeuronFactory.gen_neuron(neuron['model'])
            self.neurons[name] = _neuron(
                name, self.graph.in_degree(name),
                neural_container,
                **neuron
            )
            self.c_neurons[j] = <Neuron > self.neurons[name]

    def generate_network(self, neural_container):
        """
        Generate the network.
        """
        for name, neuron in list(self.neurons.items()):
            pylog.debug(
                'Establishing neuron {} network connections'.format(
                    name))
            for j, pred in enumerate(self.graph.predecessors(name)):
                pylog.debug(('{} -> {}'.format(pred, name)))
                #: Set the weight of the parameter
                neuron.add_ode_input(
                    j,
                    self.neurons[pred],
                    neural_container,
                    **self.graph[pred][name])

    #################### C-FUNCTIONS ####################
    cpdef double[:] ode(self, double t, double[:] state):
        self.states.c_set_values(state)
        cdef unsigned int j
        cdef Neuron neuron

        for j in range(self.num_neurons):
            neuron = self.c_neurons[j]
            neuron.c_output()

        for j in range(self.num_neurons):
            neuron = self.c_neurons[j]
            neuron.c_ode_rhs(
                self.outputs.c_get_values(),
                self.weights.c_get_values(),
                self.parameters.c_get_values()
            )
        return self.dstates.c_get_values()
