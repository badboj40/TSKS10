function [zI, zQ, A, tau] = receiver(y)

    % Konstanter
    f1 = 140e3; % 140 kHz
    f2 = 160e3; % 160 kHz
    starting_frequency = 20e3; % 20 kHz
    upsampled_frequency = 400e3; % 400 kHz
    upsampling_factor = upsampled_frequency / starting_frequency; % 20
    fc = (f1 + f2) / 2; % Bärfrekvensen
    fn = upsampled_frequency / 2; % Nyquistfrekvensen
    chirp_length = 1 * upsampled_frequency; % 1 second of 400 kHz chirp
    signal_length = 5 * upsampled_frequency; % 5 seconds of 400 kHz signal


    % Skapa tidsvektor
    time_scale = 1 / upsampled_frequency;
    t = 0:time_scale:(5-time_scale);


    % Filtrera ut önskat frekvensband med BP-filter.
    N = 100;
    delay = N / 2;
    Wn = [f1/fn f2/fn];
    [b, a] = fir1(N, Wn, "bandpass");
    y = filter(b, a, y);


    % Flytta inledande nollor till slutet
    y = y([delay+1:end 1:delay]);
        

    % Skapa en likadan chirp som i sender.
    chirp_t = 0:time_scale:(1-time_scale);
    my_chirp = chirp(chirp_t, (f1+5000),1,(f2-5000));
    

    % Hitta delay med hjälp av chirp-signalen.
    chirp_delay = finddelay(my_chirp, y);
    tau = 1e6 * chirp_delay / upsampled_frequency;


    % Hitta amplitudskalning
    max_amp = max(xcorr(y, my_chirp));
    min_amp = min(xcorr(y, my_chirp));


    % Spara den med störst absolutbelopp
    peak = (abs(max_amp) >= abs(min_amp)) * max_amp + (abs(min_amp) > abs(max_amp)) * min_amp;
    A = round(peak / norm(my_chirp)^2, 1);


    % Använd tau och A för att fixa signalen.
    y = y([chirp_delay+1:end 1:chirp_delay]) / A;

    
    % Ta bort chirp-signalen från y
    y = y(chirp_length+1:signal_length+chirp_length);


    % I/Q demodulering
    zI =  2 * y .* cos(2*pi*fc*t)';
    zQ = -2 * y .* sin(2*pi*fc*t)';


    % Skapa LP-filter
    N = 100;        
    delay = N / 2;
    Wn = 8500 / fn;
    [b, a] = fir1(N, Wn, "low");


    % LP-filtrera
    zI = filter(b, a, zI);
    zQ = filter(b, a, zQ);


    % Flytta inledande nollor till slutet
    zI = zI([delay+1:end 1:delay]);
    zQ = zQ([delay+1:end 1:delay]);


    % Downsampla signalerna tillbaka till ursprungsfrekvensen.
    zI = downsample(zI, upsampling_factor);
    zQ = downsample(zQ, upsampling_factor);

end