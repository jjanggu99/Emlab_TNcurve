function Run_for_lamda_skew(Input,i_d,i_q,f, total_angle)
%RUN_TN Summary of this function goes here
%   Detailed explanation goes here

p = Input.p;
step = Input.steps+1;
rpm = Input.base_rpm;
Motion = Input.Motion_condi;
current = sqrt(i_d^2+i_q^2);
stack=Input.Stack*Input.Stack_Margin;

if (current==0)
    phase=0;    % Lambda_fd 추출을 위한 경우
else    
    phase = atan2(i_q,i_d)*180/pi+360*(i_q<0)+90;   % IdIq 맵을 위한 경우
end

floor=Input.skew_floor;
%num_core = Input.JMAG_num_core;

current_path = [pwd '/'];
current_path = strrep(current_path,'\','/');

time=120/rpm/p/6;
time_str=num2str(time,'%10.8f');
freq=rpm*p/120;
freq_str=num2str(freq,'%10.8f');
current_str=num2str(current,'%10.8f');
phase_str=num2str(phase,'%10.8f');
total_angle_str=num2str(total_angle, '%10.8f');
stack_str=num2str(stack,'%10.8f');

fid = fopen('Run_for_lamda_skew.vbs','a');

fprintf(fid, '\nSet study = designer');    
fprintf(fid, ['\nCall study.Load("' current_path Input.JMAG_name_for_lamda '")']);                    
fprintf(fid, '\nCall study.GetModel(0).GetStudy(0).DeleteResult()'); %이전결과 삭제
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).SetName("i_d:',num2str(i_d),'/ i_q:',num2str(i_q),'_',num2str(floor),'th_skew_',num2str(f),'")']);
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStep().SetValue("EndPoint",',time_str,')']);                             %해석시간
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStep().SetValue("Step", ',num2str(step),')']);                           %step
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStep().SetValue("StepDivision",',num2str(step-1),')']);                  %division
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStudyProperties().SetValue("ModelThickness",',stack_str,')']);               %적층 길이
% fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStudyProperties().SetValue("MultiCPU", ',num2str(num_core),')']);      %Muticore
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,Motion, '").SetValue("AngularVelocity",',num2str(rpm),')']);     %회전속도
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,Motion, '").SetValue("InitialRotationAngle", ',total_angle_str,')']);   %Initial angle   
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("Amplitude",',current_str,')']);  %전류크기
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("Frequency",',freq_str,')']);     %주파수
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("PhaseU",',phase_str,')']);       %위상각
 
fprintf(fid, '\nCall study.GetModel(0).GetStudy(0).Run()');

fprintf(fid, '\nCall study.SetCurrentStudy(0)');

if (current==0)
    fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("FEMCoilFlux")');
    fprintf(fid, ['\nCall tabledata.WriteTable("' ,current_path, 'Emf_Data_Skew/Lamda_fd@',num2str(rpm),'_',num2str(floor),'th_skew_' ,num2str(f), '.csv", "Time")']);
else
    fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("FEMCoilFlux")');
    fprintf(fid, ['\nCall tabledata.WriteTable("' ,current_path, 'IdIq_Skew/' ,num2str(i_d), '_' ,num2str(i_q), '_',num2str(floor),'th_skew_' ,num2str(f), '.csv", "Time")']);
end

fprintf(fid,'\nCall study.Save()');

fprintf(fid,'\nCall study.quit');

fclose(fid);      

end

