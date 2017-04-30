function getVirdataN(FILEName, r1, r2, r3, r4, r5, r6, r7)
%%%%%%10 30 70 110 150

% % % IM = getVirdataN('face_PIE');
% % getVirdataN('face_PIE', 0.5, 0, 0, 0, 0, 0, 0)
% % getVirdataN('face_PIE', 0, 0.5, 0, 0, 0, 0, 0)
% % getVirdataN('face_PIE', 0, 0, 0.5, 0, 0, 0, 0)

% % clear all;cd 'D:\Tanmin\project\Signdetect\SignClassify';getVirdataN({'face_PIE', 110, 1, [0.1, 0.3, 0.5, 0.7]}, 1, 0, 0, 0, 0, 0, 0)
% % clear all;cd 'D:\Tanmin\project\Signdetect\SignClassify';getVirdataN({'face_PIE', 110, 1, [0.1, 0.3, 0.5, 0.7]}, 0, 1, 0, 0, 0, 0, 0)
% % clear all;cd 'D:\Tanmin\project\Signdetect\SignClassify';getVirdataN({'face_PIE', 110, 1, [0.1, 0.3, 0.5, 0.7]}, 0, 0, 1, 0, 0, 0, 0)
UseFixedSplit = 0;
if iscell(FILEName)
    UseFixedSplit = 1;
    NTrain = FILEName{2};
    NSplit = FILEName{3};
    if length(FILEName) > 3
        MRatio = FILEName{4};
    end
    FILEName = FILEName{1};
    load(fullfile('D:\Tanmin\project\Signdetect\SignClassify\TrainInfo',...
        ['image_' FILEName '_0_RoundInfo10_' num2str(NSplit) 'R_' ...
        num2str(NTrain) '.mat']), 'Trainset', 'Testset');

    load(fullfile('D:\Tanmin\project\Signdetect\SignClassify\TrainInfo',...
        ['image_' FILEName '_0_database.mat']), 'database');
    imgname = database.orgimpath(Trainset);imglabel = database.label(Trainset);
    Timgname = database.orgimpath(Testset);Timglabel = database.label(Testset);
    [a, b, c] = unique(imglabel);[Ta, Tb, Tc] = unique(Timglabel);
    cnameTest = cell(1, length(b));cnameTrain = cell(1, length(b));
    for ii = 1:length(b)
        [aa, bb ] = fileparts(imgname{b(ii)});
        [aa, bb ] = fileparts(aa);        
        Sfilenames(ii).name =  bb;
        index = find(c == ii);index = index(randperm(length(index)));
        [~, cnameTrain{ii}, cc] = cellfun(@fileparts, imgname(index), 'ErrorHandler', @errorfun, ...
            'UniformOutput', false);
        cnameTrain{ii} = cellfun(@(x, y) [x, y], cnameTrain{ii}, cc, 'ErrorHandler', @errorfun, ...
            'UniformOutput', false);
        index = find(Tc == ii);index = index(randperm(length(index)));
        [~, cnameTest{ii}, cc] = cellfun(@fileparts, Timgname(index), 'ErrorHandler', @errorfun, ...
            'UniformOutput', false);
        cnameTest{ii} = cellfun(@(x, y) [x, y], cnameTest{ii}, cc, 'ErrorHandler', @errorfun, ...
            'UniformOutput', false);
    end
end


if nargin < 2
    r1 = 0.125;
    r2 = 0.125;
    r3 = 0.125;
    r4 = 0.125;
    r5 = 0.125;
    r6 = 0.125;
    r7 = 0.125;
end



BestOCC= 0;
if r1 < 0 || r4 < 0 || r5 < 0 || r7 < 0
    BestOCC= 1;
end
r1 = abs(r1);r4 = abs(r4);r5 = abs(r5);r7 = abs(r7);

FILEName = fullfile('image', FILEName);
sr1 = num2str(r1); sr2 = num2str(r2); sr3 = num2str(r3); sr4 = num2str(r4);
sr5 = num2str(r5); sr6 = num2str(r6); sr7 = num2str(r7);
BFILEName1 = [FILEName, getVirstr(sr1), getVirstr(sr2), getVirstr(sr3), getVirstr(sr4), getVirstr(sr5), getVirstr(sr6), getVirstr(sr7)];


vType = [0, 1, 2, 3, 4, 5, 6, 7];
if UseFixedSplit
    filenames = Sfilenames;
else
    if BestOCC
    FILEName1 = [FILEName1, 'B'];
end
filenames = dir(FILEName);
end

% % % % % for i = 1:length(filenames)
% % % % %     for jj = 1:length(MRatio)
% % % % %     if length(MRatio)~=1
% % % % %         ss = num2str(MRatio(jj)); FILEName1 = [BFILEName1, '_' ss(2:end)];
% % % % %     else
% % % % %         FILEName1 = BFILEName1;
% % % % %     end
% % % % %     if UseFixedSplit
% % % % %         cimname = {cnameTrain{i}, cnameTest{i}};
% % % % %         if jj == 1
% % % % %             vittype = zeros(1, length(cnameTrain{i})+length(cnameTest{i}));idx = 0;
% % % % %             for kkk = 1:length(cimname)
% % % % %                 Numvir = round(length(cimname{kkk})*MRatio(jj)*[r1, r2, r3, r4, r5, r6, r7]);
% % % % %                 Numvir = cumsum(Numvir);
% % % % %                 Numvir1 = [1,Numvir(1:end-1)+1];
% % % % %                 for j = 1:length(Numvir)
% % % % %                     index = [Numvir1(j)+idx:Numvir(j)+idx];
% % % % %                     vittype((index)) = vType(j+1);
% % % % %                 end
% % % % %                 idx = idx + length(cimname{kkk});
% % % % %             end
% % % % %         else
% % % % %             dis = MRatio(jj)-MRatio(jj-1);idx = 0;
% % % % %             for kkk = 1:length(cimname)
% % % % %                 Numvir = round(length(cimname{kkk})*dis*[r1, r2, r3, r4, r5, r6, r7]);
% % % % %                 Numvir = cumsum(Numvir);
% % % % %                 istart = find(vittype(idx + 1:idx+length(cimname{kkk})));
% % % % %                 Numvir1 = [1,Numvir(1:end-1)+1];
% % % % %                 Numvir1 = Numvir1 + istart(end);Numvir = Numvir + istart(end);
% % % % %                 for j = 1:length(Numvir)
% % % % %                     index = [Numvir1(j)+idx:Numvir(j)+idx];
% % % % %                     vittype((index)) = vType(j+1);
% % % % %                 end
% % % % %                 idx = idx + length(cimname{kkk});
% % % % %             end
% % % % %         end
% % % % %         Scimname = cimname;cimname = [];rowHeadings = {'name'};
% % % % %         for kkk = 1:length(Scimname )
% % % % %             cimname = [cimname; cell2struct(Scimname{kkk}, rowHeadings, 1)];
% % % % %         end
% % % % %     else
% % % % %         cimname = dir(fullfile(FILEName, filenames(i).name, '*.bmp'));
% % % % %         Numvir = round(length(cimname)*[r1, r2, r3, r4, r5, r6, r7]);
% % % % %         Numvir = cumsum([length(cimname) - sum(Numvir), Numvir]);
% % % % %         if length(cimname) < 1
% % % % %             continue;
% % % % %         end
% % % % %         Numvir1 = [1,Numvir(1:end-1)+1];
% % % % %         Map = randperm(length(cimname));
% % % % %         vittype = zeros(1, length(cimname));
% % % % %         for j = 1:length(Numvir)
% % % % %             index = [Numvir1(j):Numvir(j)];
% % % % %             vittype(Map(index)) = vType(j);
% % % % %         end
% % % % %     end
% % % % %     Cvittype{i, jj} = vittype;
% % % % %     CFILEName1{jj} = FILEName1;
% % % % %     end
% % % % % end   
% % % % % for i = 1:size(Cvittype, 2)
% % % % %     Cvittype{32,i}(end+1:end+6) = 0; 
% % % % % end
% % % % % zz = 0;
% % % % % for i = 1:size(Cvittype, 1)
% % % % %     if i == 32
% % % % %         continue
% % % % %     end
% % % % %     if nnz(cell2mat(Cvittype(i, :)) - cell2mat(Cvittype(1, :)))
% % % % %         t  = 1
% % % % %         [i, j]
% % % % %         zz = zz +1;
% % % % %     end
% % % % % end
for i = 1:length(filenames)
    for jj = 1:length(MRatio)
    if length(MRatio)~=1
        ss = num2str(MRatio(jj)); FILEName1 = [BFILEName1, '_' ss(2:end)];
    else
        FILEName1 = BFILEName1;
    end
    if UseFixedSplit
        cimname = {cnameTrain{i}, cnameTest{i}};
        if jj == 1
            vittype = zeros(1, length(cnameTrain{i})+length(cnameTest{i}));idx = 0;
            for kkk = 1:length(cimname)
                Numvir = round(length(cimname{kkk})*MRatio(jj)*[r1, r2, r3, r4, r5, r6, r7]);
                Numvir = cumsum(Numvir);
                Numvir1 = [1,Numvir(1:end-1)+1];
                for j = 1:length(Numvir)
                    index = [Numvir1(j)+idx:Numvir(j)+idx];
                    vittype((index)) = vType(j+1);
                end
                idx = idx + length(cimname{kkk});
            end
        else
            dis = MRatio(jj)-MRatio(jj-1);idx = 0;
            for kkk = 1:length(cimname)
                Numvir = round(length(cimname{kkk})*dis*[r1, r2, r3, r4, r5, r6, r7]);
                Numvir = cumsum(Numvir);
                istart = find(vittype(idx + 1:idx+length(cimname{kkk})));
                Numvir1 = [1,Numvir(1:end-1)+1];
                Numvir1 = Numvir1 + istart(end);Numvir = Numvir + istart(end);
                for j = 1:length(Numvir)
                    index = [Numvir1(j)+idx:Numvir(j)+idx];
                    vittype((index)) = vType(j+1);
                end
                idx = idx + length(cimname{kkk});
            end
        end
        Scimname = cimname;cimname = [];rowHeadings = {'name'};
        for kkk = 1:length(Scimname )
            cimname = [cimname; cell2struct(Scimname{kkk}, rowHeadings, 1)];
        end
    else
        cimname = dir(fullfile(FILEName, filenames(i).name, '*.bmp'));
        Numvir = round(length(cimname)*[r1, r2, r3, r4, r5, r6, r7]);
        Numvir = cumsum([length(cimname) - sum(Numvir), Numvir]);
        if length(cimname) < 1
            continue;
        end
        Numvir1 = [1,Numvir(1:end-1)+1];
        Map = randperm(length(cimname));
        vittype = zeros(1, length(cimname));
        for j = 1:length(Numvir)
            index = [Numvir1(j):Numvir(j)];
            vittype(Map(index)) = vType(j);
        end
    end
    
    
    if ~exist(fullfile(FILEName1, filenames(i).name))
        mkdir(fullfile(FILEName1, filenames(i).name))
    end
    idx1 = find(vittype == 1);%%%%occ  
    idx2 = find(vittype == 2);%%%%Noise  
    idx3 = find(vittype == 3);%%%%Ratation  
    idx4 = find(vittype == 4);%%%%occ+Noise
    idx5 = find(vittype == 5);%%%%occ+Ratation
    idx6 = find(vittype == 6);%%%%Ratation+Noise
    idx7 = find(vittype == 7);%%%%occ+Noise+Ratation
% % % %     angleR = rand(1, length(union(idx3, idx5, idx6, idx7)))*120;
    

    for kk = [1:length(cimname)]
        imageN = fullfile(FILEName, filenames(i).name, cimname(kk).name);
        imageN1 = fullfile(FILEName1, filenames(i).name, cimname(kk).name);
        im = imread(imageN);
        imwrite(im, imageN1); 
    end
    
    
    iii = 0;
    setOCC = union(union(union(idx1, idx4), idx5), idx7);
    if BestOCC
    x1 = rand(1, length(setOCC))*(0-0.5)+0.5;
    x2 = min(x1 + rand(1, length(setOCC))*(0.5-1)+1, 1);
    y1 = rand(1, length(setOCC))*(0-0.5)+0.5;
    y2 = min(y1 + rand(1, length(setOCC))*(0.5-1)+1, 1);
    else
    x1 = rand(1, length(setOCC));
    x2 = min(x1 + rand(1, length(setOCC)), 1);
    y1 = rand(1, length(setOCC));
    y2 = min(y1 + rand(1, length(setOCC)), 1);
    end
    for kk = setOCC%%occ
%         imageN = fullfile(FILEName, filenames(i).name, cimname(kk).name);
        imageN1 = fullfile(FILEName1, filenames(i).name, cimname(kk).name);
        im = imread(imageN1);
        iii = iii +1;
        xx1 = max(round(x1(iii)*size(im, 1)), 1);
        xx2 = round(x2(iii)*size(im, 1));
        yy1 = max(round(y1(iii)*size(im, 2)), 1);
        yy2 = round(y2(iii)*size(im, 2));
%         im(xx1:xx2, yy1:yy2) = round(rand([xx2 - xx1 + 1, yy2 - yy1 + 1])*255);
%         im(xx1:xx2, yy1:yy2) = ones(xx2 - xx1 + 1, yy2 - yy1 + 1)*mean(im(:));
        im(xx1:xx2, yy1:yy2) = zeros(xx2 - xx1 + 1, yy2 - yy1 + 1);
        imwrite(im, imageN1);      
    end
    setNOISE = union(union(union(idx2, idx4), idx6), idx7);
    for kk = setNOISE%%NOISE
%         imageN = fullfile(FILEName, filenames(i).name, cimname(kk).name);
        imageN1 = fullfile(FILEName1, filenames(i).name, cimname(kk).name);
        im = imread(imageN1);ttz = 0.0005+rand(1)* 0.0195;
        im = imnoise(im, 'gaussian', 0, ttz);imshow(im)
% % % % %         j = 0;
% % % % %         for ttz = 0.0005:0.0005:0.02
% % % % %             j = j + 1;
% % % % %             subplot(8, 5, j);imshow(imnoise(im, 'gaussian', 0, ttz))
% % % % %         end
        imwrite(im, imageN1);      
    end
    setROT = union(union(union(idx3, idx5), idx6), idx7);
    angleR = (rand(1, length(setROT))-0.5)*90;
    iii = 0;
    for kk = setROT%%Ratation
        iii = iii + 1;
%         imageN = fullfile(FILEName, filenames(i).name, cimname(kk).name);
        imageN1 = fullfile(FILEName1, filenames(i).name, cimname(kk).name);
        im = imread(imageN1);im = imrotate(im, angleR(iii), 'crop');
        imwrite(im, imageN1);             
    end
    
end
end

function str = getVirstr(str)
if str2num(str) ~= round(str2num(str))
    str = str(2:end);
end