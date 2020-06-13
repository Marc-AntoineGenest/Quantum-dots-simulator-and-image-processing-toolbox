function occ_modif = image_distortion(occ, A, B, C, D)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Références :
% http://spinroot.com/pico/#E (livre: Beyond Photography - The Digital Darkroom)
% https://blogs.mathworks.com/steve/2006/08/04/spatial-transformations-defining-and-applying-custom-transforms/
% 
% Exemple de paramètres :
% - A = 0.5;
% - B = 0.6;
% - C = 0.9;
% - D = 0.35;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modification de l'image
% Fonctions à utiliser
f = @(x) [x(:,1), A*x(:,2) - B*cos(x(:,2)).^2];
g = @(x, unused) f(x);

% Distortion de l'image
tform = maketform('custom', 2, 2, [], g, []);
occ_modif = imtransform(double(occ), tform, 'nearest', 'UData', [-C 1], 'VData', [-D 1], ...
    'XData', [-1 1], 'YData', [-1 1]);