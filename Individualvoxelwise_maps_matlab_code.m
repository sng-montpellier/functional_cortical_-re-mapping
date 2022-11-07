%Individual functional maps 
%Required:SPM12


clear
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    RUN THROUGH ALL DIRECTORIES%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Select and run through all patient directories
MainDir=pwd; %makes the current directory where MATLAB the main directory
 
dirs = uigetfile_n_dir;
 
% Prep for surgery #1 or #2
subdirs{1}='S1';
subdirs{2}='S2';
 
its=0;
 
for nsurgery =1:2
    
    for caseDirs=1:length(dirs)
        
        %Go to Main directory
        cd([dirs{caseDirs},'/',subdirs{nsurgery}])
        %%% Here we run through all the stimulation points, binary + or - points
        %Run through all the directory files and find only those files that
        %start with "10mmspehere" as these are ALL stimulation point files
        fil=dir;
        lg=length(fil);
        for i=1:lg
            idx(i)=startsWith(fil(i).name,'10mm');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% Here we load EACH surgery and EACH Stim Point for each Surgery
        %%%%%% MAKE THE OVERLAP MAP FOR EACH OF S1 & S2
        idxpos=find(idx>0);
        tempVol = uint8(zeros(91,109,91));
        for j=1:length(idxpos)
            tempnii=load_nii(fil(idxpos(j)).name);
            tempniiUINT8=load_nii(fil(idxpos(j)).name);%holder for later
            tempVol=tempVol+tempnii.img;
            % These are ALL INDIVIDUAL stimulation points for surgery #{nsurgery}
            % both POSITIVE & NEGATIVE
            data(caseDirs).surgery(nsurgery).stim(j).pointsVol=load_nii(fil(idxpos(j)).name);
            tempfname=(fil(idxpos(j)).name);
            %File name for stimulation point
            data(caseDirs).surgery(nsurgery).stim(j).pointsFileName=tempfname;
            %Stimulation point ID # (=last three digits in file name)
            data(caseDirs).surgery(nsurgery).stim(j).pointsID=tempfname(end-6:end-4);
        end
        % Total number of  stimulation points
        data(caseDirs).surgery(nsurgery).stim(j).numpoints=length(idxpos);
        % OVERLAP of all stimulation points for surgeyr #{nsurgery}
        %This is the sum of all stim points for case #n https://urldefense.com/v3/__http://s.th__;!!DV4KuIgKKrh48VMFxQ!EDpDXxTFqvbLAQkiqTxZTBv57n6aOFsu5Byh6F_LFs6UGi3o09VEmFKwta-4xvjJRs6HL68sUL5yzIrLCi5bPhgS9ywd$ . the max possible
        %value for a pixel is the # of stim points b/c of max possible overlap
        data(caseDirs).surgery(nsurgery).pointsVolSum=tempVol;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%% BINARY MASK OF ALL STIMULATION POINTS per PATIENT
        %Make a [0,1] binary mask of all stim points
        idxbin=find(tempVol>0);
        data(caseDirs).surgery(nsurgery).pointsVolSumBin=tempVol;
        data(caseDirs).surgery(nsurgery).pointsVolSumBin(idxbin)=1;
        
        clear lg idx fil idxpos tempVol tempnii idxbin fil tempnii chardir
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% We run throught KERNEL files now
        %%%Run throught the POSITIVE KERNELS only
        %Here run through only the POSITIVE KERNELS
        filker=dir;
        lgker=length(filker);
        for i=1:lgker
            %Finding files that start with prefix used for Kernel files
            idxker(i)=startsWith(filker(i).name,'00_');
        end
        
        idxposker=find(idxker>0);
        %Load kernel files
        % If no points then make empty volume
        if (isempty(idxposker)==1)
            data(caseDirs).surgery(nsurgery).kernel(j).numpoints=0;
            tempVolker = single(zeros(91,109,91));
        else
            tempVolker = single(zeros(91,109,91));
            for j=1:length(idxposker)
                tempniiker=load_nii(filker(idxposker(j)).name);
                tempniiSINGLE=load_nii(filker(idxposker(j)).name);%holder for later
                tempniikerSINGLE=tempniiker;
                tempfnameker=(filker(idxposker(j)).name);
                tempVolker=tempVolker+tempniiker.img;
                data(caseDirs).surgery(nsurgery).kernel(j).pointsVol=load_nii(filker(idxposker(j)).name);
                data(caseDirs).surgery(nsurgery).kernel(j).pointsID=tempfnameker(end-9:end-7);
            end
            data(caseDirs).surgery(nsurgery).kernel(j).numpoints=length(idxposker);
            
            
        end
        % OVERLAP of all kernel points for surgery #{nsurgery}
        %This is the sum of all kernel points for case #n https://urldefense.com/v3/__http://s.th__;!!DV4KuIgKKrh48VMFxQ!EDpDXxTFqvbLAQkiqTxZTBv57n6aOFsu5Byh6F_LFs6UGi3o09VEmFKwta-4xvjJRs6HL68sUL5yzIrLCi5bPhgS9ywd$ . the max possible
        %value for a pixel is the # of kernel points b/c of max possible overlap
        data(caseDirs).surgery(nsurgery).kernelVolSum=tempVolker;
        clear idxker filker lgker idxposker tempniiker tempVolker tempfnameker
        %write all poijts
        cd([dirs{caseDirs},'/',subdirs{nsurgery}])
 
        tempMap= data(caseDirs).surgery(nsurgery).pointsVolSumBin;
        tempniiUINT8.img=tempMap;
        save_nii(tempniiUINT8,['pointsVolSumBin.nii']);
        
        tempMap= data(caseDirs).surgery(nsurgery).pointsVolSum;
        tempniiUINT8.img=tempMap;
        save_nii(tempniiUINT8,['pointsVolSum.nii']);
        
        tempMap= data(caseDirs).surgery(nsurgery).kernelVolSum;
        tempniiSINGLE.img=tempMap;
        save_nii(tempniiSINGLE,['kernelVolSum.nii']);
    end
    
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%%%%%%%% INTERSECTION of S1 & S2
%Now, we create "intersection masks for each patient, https://urldefense.com/v3/__http://s.th__;!!DV4KuIgKKrh48VMFxQ!EDpDXxTFqvbLAQkiqTxZTBv57n6aOFsu5Byh6F_LFs6UGi3o09VEmFKwta-4xvjJRs6HL68sUL5yzIrLCi5bPhgS9ywd$ . the
%intersection mask for each patient are the pixels that are stimulaed in
%both S1 and S2 surgery
 
for caseDirs=1:length(dirs)
    tempMap = uint8(zeros(91,109,91));
    tempSumOverlap= uint8(zeros(91,109,91));
    temp1=data(caseDirs).surgery(1).pointsVolSumBin;
    temp2=data(caseDirs).surgery(2).pointsVolSumBin;
    tempsum=temp1+temp2;
    idxsum=find(tempsum>1);
    tempMap(idxsum)=1;
    % This is the INTERSECTION of S1 & S2 in BINARY format
    data(caseDirs).S1S2intersection=tempMap;%Binary [0,1] mask of intersections
    tempSumOverlap(idxsum)=tempsum(idxsum);
    data(caseDirs).S1S2intersectionOverlap=tempSumOverlap;%overlap of all occurences [0,n]
    clear tempMap tempSumOverlap tempsum idxsum
    cd([dirs{caseDirs},'/',subdirs{nsurgery}])
    
    tempMap= data(caseDirs).S1S2intersection;
    tempniiUINT8.img=tempMap;
    save_nii(tempniiUINT8,['S1S2intersection.nii']);
    
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% OVERLAP MAP AT THE INTERSECTION
% At the INDIVIDUAL PATIENT LEVEL
%Now, we create the overlap maps for each surgery S1 and S2, such that it
%only includes the overlaps that are found at the intersection of S1 and S2,
%NB, this are the SUM of the individual points for S1 and separately for S2
for caseDirs=1:length(dirs)
    for nsurgery=1:2
        tempMap=data(caseDirs).S1S2intersection;
        idx=find(tempMap==0);
        temp=data(caseDirs).surgery(nsurgery).pointsVolSum;
        temp(idx)=0;
        data(caseDirs).surgery(nsurgery).pointsVolSumIntersection=temp;
        
        cd([dirs{caseDirs},'/',subdirs{nsurgery}])       
        tempMap= data(caseDirs).surgery(nsurgery).pointsVolSumIntersection;
        tempniiUINT8.img=tempMap;
        save_nii(tempniiUINT8,['pointsVolSumIntersection.nii']);
    end
    clear idx temp tempMap
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% KERNELS AT THE INTERSECTION
% At the INDIVIDUAL PATIENT LEVEL
%Now, we create the kernel maps for each surgery S1 and S2, such that it
%only includes the kernels that are found at the intersection of S1 and S2,
%NB, this are the SUM of the kernels for S1 and separately for S2
for caseDirs=1:length(dirs)
    for nsurgery=1:2
        tempMap=data(caseDirs).S1S2intersection;
        idx=find(tempMap==0);
        tempKer=data(caseDirs).surgery(nsurgery).kernelVolSum;
        tempKer(idx)=0;
        data(caseDirs).surgery(nsurgery).kernelVolSumIntersection=tempKer;
 
        cd([dirs{caseDirs},'/',subdirs{nsurgery}])
 
        tempMap= data(caseDirs).surgery(nsurgery).kernelVolSumIntersection;
        tempniiSINGLE.img=tempMap;
        save_nii(tempniiSINGLE,['kernelVolSumIntersection.nii']);
    end
    clear idx tempKer tempMap
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%NORMALIZED MAPS%%%%%%%%%%%%%%%%%%%%%%%%
 
for caseDirs=1:length(dirs)
    for nsurgery=1:2
        normMap = single(zeros(91,109,91));
        temp=data(caseDirs).surgery(nsurgery).pointsVolSumIntersection;
        tempKer=data(caseDirs).surgery(nsurgery).kernelVolSumIntersection;
        idxpts=find(temp>=0);
        idxker=find(tempKer>=0);
        normMap(idxker) = single(tempKer(idxker))./single(temp(idxker));
        data(caseDirs).surgery(nsurgery).kernelVolSumIntersectionNormalized=...
            normMap;
        cd([dirs{caseDirs},'/',subdirs{nsurgery}])
        
        tempMap= data(caseDirs).surgery(nsurgery).kernelVolSumIntersectionNormalized;
        tempniiSINGLE.img=tempMap;
        save_nii(tempniiSINGLE,['kernelVolSumIntersectionNormalized.nii']);
    end
    clear  tempKer temp idxpots idxker normMap
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These are the POPULATION MAPS for POINTS and KERNELS for S1 and S2
% The MAPS are separately save as the variable MAPS for S2 or S2
% MAPS is indexed as MAPS(1) for S1 and MAPS(2) for S2
% The STIMULATION POINTS - all points and only those at the intersetion
%     pointsVolSum=temp1;
%     pointsVolSumIntersection=temp2;
% The KERNEL POINTS - all point sand only those at the intersection
%     kernelVolSum=temp3;
%     kernelVolSumIntersection=temp4;
% The KERNEL POINTS normalized by the STIMULATION POINTS at the intersection
%     kernelVolSumIntersectionNormalized=temp5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
for nsurgery=1:2
    % Population overlap Maps
    temp1 = uint8(zeros(91,109,91));
    temp2 = uint8(zeros(91,109,91));
    temp3 = single(zeros(91,109,91));
    temp4 = single(zeros(91,109,91));
    for caseDirs=1:length(dirs)
        temp1=temp1+data(caseDirs).surgery(nsurgery).pointsVolSum;
        temp2=temp2+data(caseDirs).surgery(nsurgery).pointsVolSumIntersection;
        temp3=temp3+data(caseDirs).surgery(nsurgery).kernelVolSum;
        temp4=temp4+data(caseDirs).surgery(nsurgery).kernelVolSumIntersection;
    end
    temp5 = single(zeros(91,109,91));
    idxpts=find(temp2>=0);
    idxker=find(temp4>=0);
    temp5(idxker) = single(temp4(idxker))./single(temp2(idxker));
    %Population Overlap Maps
    maps(nsurgery).pointsVolSum=temp1;
    maps(nsurgery).pointsVolSumIntersection=temp2;
    maps(nsurgery).kernelVolSum=temp3;
    maps(nsurgery).kernelVolSumIntersection=temp4;
    maps(nsurgery).kernelVolSumIntersectionNormalized=temp5;
    
end
clear temp1 temp2 temp3 temp4 temp5 idxpts idxker
%% FOR SAVING
% To save volumes of interest, you can use the following based on whether
% the original data is SINGLE (i.e., kernels) or UINT8 (i.e., points)
% Use tempniiSINGLE or tempniiUINT8 and then the following as an example
%%%%%%%%
 
% tempMap= maps(nsurgery).kernelVolSumIntersectionNormalized;
% tempniiSINGLE.img=tempMap;
% save_nii(tempniiSINGLE,['kernelVolSumIntersectionNormalized.nii']);
%%%%%%%%
% This code will save the maps in the correct orientation, etc. as they are
% rotated 90 degrees when visualized in MATLAB but will be saved in corrected
% orientation using this set up and the LOAD and SAVE functions
% This is an artifact of MNI space and the load_nii/save_nii files
% As long as you use the load_nii and save_nii, the input and output are
% all compatible with MNI space, its just that when you visualize in MATLAB
% it arranges it as such
%% NEXT TWO SECTIONS ARE FOR VISUALIZATION
% Visualize results for surgery of interest
its=0;
for slc=1:2:90 %choose which slice to visualize
    for nsurgery=1:2% choose to visualize S1 or S2
        subplot(2,5,(nsurgery*5-4))
        imagesc(maps(nsurgery).pointsVolSum(:,:,slc))
        axis image, title('Overlap')
        subplot(2,5,(nsurgery*5-3))
        imagesc(maps(nsurgery).pointsVolSumIntersection(:,:,slc))
        axis image, title('Intersection S1 & S2')
        subplot(2,5,(nsurgery*5-2))
        imagesc(maps(nsurgery).kernelVolSum(:,:,slc))
        axis image, title('Kernel Overlap')
        subplot(2,5,(nsurgery*5-1))
        imagesc(maps(nsurgery).kernelVolSumIntersection(:,:,slc))
        axis image, title('Kernel Overlap @ Intersection')
        subplot(2,5,(nsurgery*5-0))
        imagesc(maps(nsurgery).kernelVolSumIntersectionNormalized(:,:,slc))
        axis image, title('Normalized - Kernel/Overlap')
    end
    pause(0.4)
end
 
%% Display check
% % OVERLAP of all stimulation points for surgeyr #{nsurgery}
% data(caseDirs).surgery(nsurgery).pointsVolSum=tempVol;
% %%%%%% BINARY MASK OF ALL STIMULATION POINTS per PATIENT
% data(caseDirs).surgery(nsurgery).pointsVolSumBin(idxbin)=1;
% % OVERLAP of all kernel points for surgery #{nsurgery}
% data(caseDirs).surgery(nsurgery).kernelVolSum=tempVolker;
% % INTERSECTION for each surgery #{nsurgery}
% data(caseDirs).S1S2intersection;%Binary [0,1] mask of intersections
% %%%%%%%%%% KERNELS AT THE INTERSECTION for each surgery
% data(caseDirs).surgery(nsurgery).kernelVolSumIntersection;
close all
for caseDirs=1
    for nsurgery=1:2;
        
        for slc=55
            subplot(2,3,1)
            imagesc(data(caseDirs).surgery(nsurgery).pointsVolSum(:,:,slc));
            axis image, title('Overlap')
            subplot(2,3,2)
            imagesc(data(caseDirs).surgery(nsurgery).pointsVolSumBin(:,:,slc));
            axis image, title('Overlap Binary')
            subplot(2,3,3)
            imagesc(data(caseDirs).S1S2intersection(:,:,slc))
            axis image, title('Intersection S1 & S2')
            subplot(2,3,4)
            imagesc(data(caseDirs).surgery(nsurgery).kernelVolSum(:,:,slc));
            axis image, title('Kernel Overlap')
            subplot(2,3,5)
            imagesc(data(caseDirs).surgery(nsurgery).kernelVolSumIntersection(:,:,slc));
            axis image, title('Kernel Overlap @ Intersection')
            subplot(2,3,6)
            imagesc(data(caseDirs).surgery(nsurgery).kernelVolSumIntersectionNormalized(:,:,slc));
            axis image, title('Normalized - Kernel/Overlap')
            pause(.5)
        end
    end
end

