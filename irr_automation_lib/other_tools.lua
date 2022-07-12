-- Vector3 構造体. new メソッドでインスタンス化可能.
Vector3 =
{
    new = function(x, y, z)

        return
        {
            x = x,
            y = y,
            z = z,

            -- 自身の座標と他の座標の相対距離を取得する
            getDistance = function(self, vector3)

                local x = (self.x - vector3.x) ^ 2
                local y = (self.y - vector3.y) ^ 2
                local z = (self.z - vector3.z) ^ 2

                -- ユークリッド距離
                local distance = (x + y + z) ^ 0.5

                return distance

            end,
        }

    end,
}