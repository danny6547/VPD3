function coeff=FindWindCoeff(winddirection,windcoefficients)

windcoeffs_angles=table2array(windcoefficients(:,1));
windcoeffs_coeffs=table2array(windcoefficients(:,2));
%winddir=table2array(winddirection);

%coeff_indice=zeros(length(winddirection),1)

% figure
hold on

% plot(windcoeffs_angles,windcoeffs_coeffs)

for i=1:length(winddirection)
    
[~,coeff_indice]=(min(abs(windcoeffs_angles-winddirection(i))));

coeff(i)=windcoeffs_coeffs(coeff_indice);


end

% plot(winddirection,coeff,'.')

end