import setuptools

setuptools.setup(name='network_generator',
                 version='0.1',
                 description='Module generate, develop and visualize neural networks',
                 url='https://gitlab.com/BioRobAnimals/NetworkGenerator.git',
                 author='Shravan Tata Ramalingasetty',
                 author_email='shravantr@gmail.com',
                 license='MIT',
                 packages=setuptools.find_packages(
                    exclude=['tests*']),
                 zip_safe=False)
