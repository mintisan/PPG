%-----------------------------%%-----------------------------%%
%  Authors: Alessandra Galli, Claudio Narduzzi, Giada Giorgi. %
%        Instrumentation and Measurement Research Group       %
%                    University of Padova                     %
%-----------------------------%%-----------------------------%%
close all;
clear all;

for k=1:12
    if k < 10
%         filename = char(strcat('.\DATABASE\Training_data\DATA_',num2str(0),num2str(k),'_TYPE02.MAT'));
        filename = char(strcat('.\DATABASE\Competition_data\TEST_S',num2str(0),num2str(k),'_T02.MAT'));
    else
%         filename = char(strcat('.\DATABASE\Training_data\DATA_',num2str(k),'_TYPE02.MAT'));
        filename = char(strcat('.\DATABASE\Competition_data\TEST_S',num2str(k),'_T02.MAT'));
    end
    matObj = matfile(filename);
    Tracce=matObj.sig;
    if k< 10
%         fn=char(strcat('.\DATABASE\Training_data\DATA_',num2str(0),num2str(k),'_TYPE02_BPMtrace.MAT'));
        fn=char(strcat('.\DATABASE\Competition_data\True_S',num2str(0),num2str(k),'_T02.MAT'));
    else
%         fn=char(strcat('.\DATABASE\Training_data\DATA_',num2str(k),'_TYPE02_BPMtrace.MAT'));
        fn=char(strcat('.\DATABASE\Competition_data\True_S',num2str(k),'_T02.MAT'));
    end
    matObj=matfile(fn);
    BPM0=matObj.BPM0;

    if(min(size(Tracce))==6)    %training trace
        ECG=Tracce(1,:);
        PPG1=Tracce(2,:);
        PPG2=Tracce(3,:);
        AX=Tracce(4,:);
        AY=Tracce(5,:);
        AZ=Tracce(6,:);
    else                       % competition trace
        PPG1=Tracce(1,:);
        PPG2=Tracce(2,:);
        AX=Tracce(3,:);
        AY=Tracce(4,:);
        AZ=Tracce(5,:);
    end

    N=length(PPG1); 
    K=1000;         
    DK=250;         
    i=1; fin=0;
    n=length(Tracce);
    specgram1 = [];
    specgram2 = [];
    specgram_denoised1 = [];
    specgram_denoised2 = [];
    while fin < n - DK

        in=(i-1)*DK+1;
        fin=in+K-1;
        ppg1=PPG1(in:fin); 
        ppg2=PPG2(in:fin);
        accx=AX(in:fin);
        accy=AY(in:fin);
        accz=AZ(in:fin);
        [temp1,temp2]=signal_denoising(ppg1,ppg2,accx,accy,accz);
        [spectrum1, spectrum2, spectrum_denoised1 ,spectrum_denoised2, z_ppg1(i) z_ppg2(i)] = frequency_analysis(ppg1,ppg2,temp1,temp2);
        specgram1(:,i) = spectrum1;
        specgram2(:,i) = spectrum2;
        specgram_denoised1(:,i) = spectrum_denoised1;
        specgram_denoised2(:,i) = spectrum_denoised2;
        i=i+1;
    end
    h = figure(k);				% 创建图形窗口

    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');	% 关闭相关的警告提示（因为调用了非公开接口）
    jFrame = get(h,'JavaFrame');	% 获取底层 Java 结构相关句柄吧
    pause(0.1);					% 在 Win 10，Matlab 2017b 环境下不加停顿会报 Java 底层错误。各人根据需要可以进行实验验证
    set(jFrame,'Maximized',1);	%设置其最大化为真（0 为假）
    pause(0.1);					% 个人实践中发现如果不停顿，窗口可能来不及变化，所获取的窗口大小还是原来的尺寸。各人根据需要可以进行实验验证
    warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');		% 打开相关警告设置
    
    subplot(2,2,1);
%     specgram1 = flipud(specgram1);
    imagesc(specgram1);
    hold on;plot(BPM0,'r');
    set(gca,'YDir','normal'); 
    subplot(2,2,2);
%     specgram2 = flipud(specgram2);
    imagesc(specgram2);
    hold on;plot(BPM0,'r');
    set(gca,'YDir','normal'); 
    subplot(2,2,3);
%     specgram_denoised1 = flipud(specgram_denoised1);
    imagesc(specgram_denoised1);
    hold on;plot(BPM0,'r');
    set(gca,'YDir','normal'); 
    subplot(2,2,4);
%     specgram_denoised2 = flipud(specgram_denoised2);
    imagesc(specgram_denoised2);
    hold on;plot(BPM0,'r');
	set(gca,'YDir','normal'); 
    
    print(gcf, '-r300','-djpeg', "./DATI_RES/"+ num2str(k)+"SPECGRAM.jpeg")
    close all;
end
