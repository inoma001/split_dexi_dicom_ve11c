function matlab_get_TReff(folderName)


%ICE recon stores data in mosaic format
mosaic=1;


[images, headers, nFiles] = dicomfolder(folderName,mosaic); %replace dataset with filename and path

pause(1);

if nFiles <4 % used for M0 with seperate TE1 and TE2 data acquired with grappa acceleration

        %calculate TReff from image acquisition times
	for i=1:3
   		temp=headers{i}.AcquisitionTime;
   		acq_sec(i)=str2double(temp(1:2))*3600 + str2double(temp(3:4))*60 + str2double(temp(5:end));
	end
	TReff=acq_sec(3)-acq_sec(1);


else % used for DEXI acquisitions

	%calculate TReff from image acquisition times
	for i=1:4
   		temp=headers{i}.AcquisitionTime;
   		acq_sec(i)=str2double(temp(1:2))*3600 + str2double(temp(3:4))*60 + str2double(temp(5:end));
	end

	if (isfield(headers{1}, 'Private_0051_1011')) % check if acceleration used (to see if integrated M0 acquired)
    		TReff=acq_sec(3)-acq_sec(1);
	else
    		TReff=acq_sec(4)-acq_sec(2);
	end

end


TReff = num2str(round(TReff, 2, 'significant'));

% write result to text file

fileID = fopen([folderName '/TReff.txt'],'w');
fprintf(fileID, TReff);
fclose(fileID);
%exit matlab 
exit
