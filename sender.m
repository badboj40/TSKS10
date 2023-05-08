function x = sender(xI, xQ)
    
    % Konstanter
    f1 = 140e3; % 140 kHz
    f2 = 160e3; % 160 kHz
    starting_frequency = 20e3; % 20 kHz
    upsampled_frequency = 400e3; % 400 kHz
    upsampling_factor = upsampled_frequency / starting_frequency; % 20
    fc = (f1 + f2) / 2; % Bärfrekvensen
    fn = upsampled_frequency / 2; % Nyquistfrekvensen
    

    % Uppsampla xI och xQ från 20 kHz till 400 kHz samplefrekvens.
    xI = upsample(xI, upsampling_factor);
    xQ = upsample(xQ, upsampling_factor);


    % Skapa tidsvektor
    time_scale = 1 / upsampled_frequency;
    t = 0:time_scale:(5-time_scale);


    % Skapa LP-filter
    N = 100;        
    delay = N / 2;
    Wn = 8500 / fn;
    [b, a] = fir1(N, Wn, "low");


    % LP-filtrera
    xI = filter(b, a, xI);
    xQ = filter(b, a, xQ);


    % Kompensera för effektskalningen
    xI = xI * upsampling_factor;
    xQ = xQ * upsampling_factor;


    % Flytta inledande nollor till slutet
    xI = xI([delay+1:end 1:delay]);
    xQ = xQ([delay+1:end 1:delay]);


    % I/Q-modellera
    x = xI .* cos(2*pi*fc*t).' - xQ .* sin(2*pi*fc*t).';


    % Skapa chirp
    chirp_t = 0:time_scale:(1-time_scale);
    my_chirp = chirp(chirp_t, (f1+5000),1,(f2-5000));


    % Lägg till chirp till x
    x = [my_chirp x']';

end
