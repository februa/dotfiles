function build
    if test -x (command -v clang)
        cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
        if test -x (command -v compdb)
            compdb list > ../compile_commands.json
        else
            echo "\e[33mWarning: compdb is not installed"
        end
    else
        cmake ..
        echo "\e[33mWarning: clang is not installed, using default compiler"
    end
end

