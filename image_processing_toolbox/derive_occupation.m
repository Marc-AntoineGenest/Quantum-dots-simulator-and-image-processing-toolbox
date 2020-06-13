function occupation_ligne = derive_occupation(occupation)
occupation_diff1 = diff(occupation, 1, 1);
occupation_diff2 = diff(occupation, 1, 2);
occupation_ligne = occupation_diff1(:,1:end-1) + occupation_diff2(1:end-1,:);
occupation_ligne(occupation_ligne>=1) = 1;
occupation_ligne(occupation_ligne<0) = 0;