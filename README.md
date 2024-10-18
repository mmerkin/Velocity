# Velocity
The code I used to process the velocity dataset


# Steps:

1) Filter museum -> develop filtering pipeline -> Atlas
2) Filter modern -> develop filtering pipeline -> Standard eg bcftools
3) Calculate average coverage for all individuals
4) Downsample modern samples to be in line with museum using atlas
5) Use modern samples to make predictions about museum samples eg use LD to estimate Ne etc and see how it compares to the data
