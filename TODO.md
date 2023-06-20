## TODO

1. Allow offscreen rendering via MESA or EGL (ideally EGL, since it's hardware-accelerated,
	which is needed for this project to be real-time)

2. Allow for GPU prediction via either CUDA or MPS (MPS will involve the most work to add.
	For the parts that do `model = model.cuda()`, add an MPS part for each one of those.
	I might have to do more than that though.)

3. Patch the convolution bug mentioned in the CodeTalker README
