module IOHelper

    def read_in_file(full_path, &block)
        data = ""

        if !File.directory?(full_path)
            IO.foreach full_path do |line|
                data += block_given? ? yield(line) : line
            end
        end

        data
    end
    
    def copy_full_dir(orig, target)
        FileUtils.cp_r(orig, target)
    end

    def delete_full_dir(directory)
        FileUtils.rm_r(directory)
    end

    def delete_full_dir_contents(directory)
        FileUtils.rm_r(Dir.glob("#{directory}*"))
    end

    def save(lines, file_to_write)
        File.open(file_to_write, "w") do |file|
            file.syswrite lines
        end
    end

    def append(lines, file_to_append)
        File.open(file_to_append, "a") do |file|
            file.syswrite lines
        end
    end

end