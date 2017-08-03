% Define a starting folder.
start_path = fullfile('A:\Fonts\FontsUpper\');
topLevelFolder = start_path;

% Get list of all subfolders.
allSubFolders = genpath(topLevelFolder);

% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);

% Process all image files in those folders.
first_image = true; %This variable is going to check whether the dataBase should be created or concatenated
for k = 1 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	fprintf('Processing folder %s\n', thisFolder);
	
	% Get BMP files.
	filePattern = sprintf('%s/*.bmp', thisFolder);
	baseFileNames = dir(filePattern);

    numberOfImageFiles = length(baseFileNames);
	
    % Now we have a list of all files in this folder.
	if numberOfImageFiles >= 1
		% Go through all those image files.
		for f = 1 : numberOfImageFiles
			fullFileName = fullfile(thisFolder, baseFileNames(f).name);
			fprintf('     Processing image file %s\n', fullFileName);
            
            %Image Processing
            image       = imread(fullFileName,'bmp'); %Stores the bmp image in a 95x44x3 matrix
            GR_image    = rgb2gray(image);         %Converts image to grayscale form
            BW_image    = im2bw(GR_image);         %Converts image to binary form
            V_image     = reshape(BW_image,[],1); %Reshape the image in order to transform it to a vector
            
            %Image Storing
            if first_image == true;
                dataBase = V_image;
                first_image = false;
            else
                dataBase = horzcat(dataBase,V_image); %The Matrix is being concatenated here
            end
		end
	else
		fprintf('     Folder %s has no image files in it.\n', thisFolder);
	end
end

%%Creating Output
Output = diag(ones([1,26]));
Output = repmat(Output,1,size(dataBase,2)/26);

%Creating and Training Newtork
net1 = feedforwardnet(25);
net1.divideFcn = '';
net1 = train(net1,dataBase,Output);

%Post-processing procedure
%Let's suppose we would like to know if the network is going to classify
%the letter A of the first font type
%So, we are calling Va the output vector of this simulation
Va = sim(net1,dataBase(:,1));

%Now, we should convert this output to only binary numbers.
%A simple way of doing this is by selecting the biggest value
%and storing its position in another variable.
%This way the position represents the letter in the alphabet.

max = Va(1);
maxPos = 1;
for n = 1 : 26
    if Va(n) > max
        max = Va(n);
        maxPos = n;
    end
end

%Now, we can convert this to a letter output.
alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
resultLetter = alphabet(maxPos);

%The user can test different letters by using the command sim using the
%desired column.

%Now, asking the user for the letter and font
answer = 'y';
while(strcmp(answer,'y'))
    
    letter = 0;
    while(letter <= 0 || letter > 26)
        prompt = 'Type the letter you would like to test. Only numbers between 1 and 26 are valid.\n';
        letter = input(prompt);
    end
    
    font = 0;
    while(font <= 0 || font > 34)
        prompt = 'Type the number of the font you would like to test\n';
        font = input(prompt);
    end
    
    Vl = sim(net1,dataBase(:,((font*26)+letter)));
    max = Vl(1);
    maxPos = 1;
    for n = 1 : 26
        if Vl(n) > max
            max = Vl(n);
            maxPos = n;
        end
    end
    
    resultLetter = alphabet(maxPos)
    
    prompt = 'Would you like to continue?\n';
    answer = input(prompt,'s');
    
    if strcmp(answer,'y') || strcmp(answer,'Y') || strcmp(answer,'yes') || strcmp(answer,'Yes') || strcmp(answer,'YES')
        answer = 'y';
    else
        answer = 'n';
    end
end