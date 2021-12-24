function Untitled = importfile(filename, dataLines)
%IMPORTFILE 从文本文件中导入数据
%  UNTITLED = IMPORTFILE(FILENAME)读取文本文件 FILENAME 中默认选定范围的数据。  返回数值数据。
%
%  UNTITLED = IMPORTFILE(FILE, DATALINES)按指定行间隔读取文本文件 FILENAME
%  中的数据。对于不连续的行间隔，请将 DATALINES 指定为正整数标量或 N×2 正整数标量数组。
%
%  示例:
%  Untitled = importfile("D:\SJTU\Bachelor\2021-2022,1\粘性流体力学\hw\proj2\data\00001.dat", [2, Inf]);
%
%  另请参阅 READTABLE。
%
% 由 MATLAB 于 2021-12-23 16:38:12 自动生成

%% 输入处理

% 如果不指定 dataLines，请定义默认范围
if nargin < 2
    dataLines = [2, Inf];
end

%% 设置导入选项并导入数据
opts = delimitedTextImportOptions("NumVariables", 4);

% 指定范围和分隔符
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 指定列名称和类型
opts.VariableNames = ["X", "Y", "U", "V"];
opts.VariableTypes = ["double", "double", "double", "double"];

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 导入数据
Untitled = readtable(filename, opts);

%% 转换为输出类型
Untitled = table2array(Untitled);
end
