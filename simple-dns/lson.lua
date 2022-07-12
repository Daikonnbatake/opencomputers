serialization = require('serialization')
filesystem = require('filesystem')

-- lua テーブルをファイルに読み書きする
Lson =
{
    load = function (path)
        -- path が存在しないときは nil を返す
        if not(filesystem.exists(path)) then return nil end

        -- path がディレクトリなら nil を返す
        if filesystem.isDirectory(path) then return nil end

        local file = filesystem.open(path, 'r')
        local lson_string = file:read(1048576)
        file:close()

        -- もしファイルサイズが 2KB 以上ならエラーにする
        if #lson_string < filesystem.size(path) then
            print('2KB 以上のjsonファイルを読み取ることはできません')
            return nil
        end

        return serialization.unserialize(lson_string)
    end,

    write = function (path, object)

        local file = filesystem.open(path, 'w')
        local lson_string = file:write(serialization.serialize(object))
        file:close()

    end
}