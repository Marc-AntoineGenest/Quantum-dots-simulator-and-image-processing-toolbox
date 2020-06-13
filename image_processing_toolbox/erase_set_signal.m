function occ_modif = erase_set_signal(occ, A, B, threshold, a, b, c, d)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exemple de paramètres :
% A = 0.01;
% B = 0.01;
% threshold = 0.95;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_signal = sin(A.*ones(size(occ)).*(1:1:size(occ,2)) +...
    B.*ones(size(occ)).*(1:1:size(occ,2))');
if a ~= 0 && b ~= 0 && c ~= 0 && d ~= 0
    set_signal = image_distortion(set_signal, a, -b, c, d);
end
occ_modif = occ;
occ_modif(set_signal>threshold | set_signal<-threshold) = 0;