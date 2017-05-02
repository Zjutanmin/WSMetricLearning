function im = imreadx(ex)

% Read a training example image.
%
% ex  an example returned by pascal_data.m
im = color(imread(ex));