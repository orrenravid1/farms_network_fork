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

Header for Node Base Struture.

"""


cdef packed struct Node:
    # Generic parameters
    unsigned int nstates
    unsigned int nparameters
    unsigned int ninputs

    char* model_type
    char* name

    bint statefull

    void* states

    # Parameters
    void* parameters

    # Functions
    void ode(
        double time,
        double[:] states,
        double[:] dstates,
        double[:] inputs,
        double[:] weights,
        double[:] noise,
        Node node
    )
    double output(double time, double[:] states, Node node)


cdef:
    void ode(
        double time,
        double[:] states,
        double[:] dstates,
        double[:] inputs,
        double[:] weights,
        double[:] noise,
        Node node
    )
    double output(double time, double[:] states, Node node)


cdef class PyNode:
    """ Python interface to Node C-Structure"""

    cdef:
        Node* _node
