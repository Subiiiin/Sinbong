function time = timecheck(T)

min = fix(T/60);
sec = rem(T, 60);
sec = fix(sec/1);

if min == 0
    Str_min = '00';
elseif fix(min/10) == 0
    Str_min = ['0' num2str(min)];
else
    Str_min = num2str(min);
end

if sec == 0
    Str_sec = '00';
elseif fix(sec/10) == 0
    Str_sec = ['0' num2str(sec)];
else
    Str_sec = num2str(sec);
end

time = [Str_min, ':', Str_sec];
end