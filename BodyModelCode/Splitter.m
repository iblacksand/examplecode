function Streams = Splitter(input_stream,splitting_vector, olds)
% Splitter Splits input stream according to splitting vector
    if abs(sum(splitting_vector) - 1) > .01
        error("splitting vector does not add to 1");
    end
    Streams = {};
    for i = 1:length(splitting_vector)
        new_stream = input_stream;
        new_stream.vflow = splitting_vector(i)*input_stream.vflow;
        Streams = {Streams{:}, new_stream};
    end
end