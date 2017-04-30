function dogFilterImage = dogImage(grayImage, hsize, sigma0, sigma1)
gaussian1 = fspecial('Gaussian', hsize, sigma0);
gaussian2 = fspecial('Gaussian', hsize, sigma1);
dog = gaussian1 - gaussian2;
dogFilterImage = conv2(double(grayImage), dog, 'same');