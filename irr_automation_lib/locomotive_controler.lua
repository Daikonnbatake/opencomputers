require('other_tools')

-- 機関車操縦クラス. インスタンス化不可.
LocomotiveControler =
{
    -- ir_remote_control API
    IR_CONTROL = require('component').ir_remote_control,

    -- computer API
    COMPUTER = require('computer'),


    -- 機関車のスロットル量(-1 ~ 1)
    locomotive_throttle = 0,

    -- 機関車のブレーキ量(0 ~ 1)
    locomotive_brake = 1,


    -- 前回サンプリングした時間をメモしておくフィールド(number)
    last_sampling_time = 0,


    -- 前回サンプリングした座標をメモしておくフィールド(Vector3)
    last_position = Vector3.new(0, 0, 0),


    -- 位置を Vector3 型で取得
    getPos = function (self)

        local x, y, z = self.IR_CONTROL.getPos()
        local position = Vector3.new(x, y, z)
        return position

    end,


    -- 時速を取得
    getSpeed = function(self)

        local now_position = self:getPos()
        local distance = now_position:getDistance(self.last_position)

        local now_time = self.COMPUTER.uptime()
        local difference_time = now_time - self.last_sampling_time

        self.last_position = now_position
        self.last_sampling_time = now_time

        -- 秒速(m)を求める
        local km_per_sec = distance / difference_time

        -- 時速(km)を求める
        local km_per_hour = (km_per_sec * 3600) / 1000

        return km_per_hour

    end,


    -- 現在のスロットルを取得
    getThrottle = function (self)

        return self.locomotive_throttle

    end,


    -- 現在のブレーキを取得
    getBrake = function (self)

        return self.locomotive_brake

    end,


    -- スロットルを -1 ~ 1 の間で設定(エイリアス)
    setThrottle = function(self, throttle)

        self.locomotive_throttle = throttle
        self.IR_CONTROL.setThrottle(throttle)

    end,


    -- スロットルを加算して現在のスロットル量を返す
    addThrottle = function (self, add)

        local throttle = self.locomotive_throttle
        local set_throttle = math.max(-1, math.min(1, throttle + add))

        self.locomotive_throttle = set_throttle
        self.IR_CONTROL.setThrottle(set_throttle)

        return set_throttle

    end,


    -- ブレーキを加算して現在のブレーキ量を返す
    addBrake = function (self, add)

        local brake = self.locomotive_brake
        local set_brake = math.max(0, math.min(1, brake + add))

        self.locomotive_brake = set_brake
        self.IR_CONTROL.setBrake(set_brake)

        return set_brake

    end,


    -- ブレーキを 0 ~ 1 の間で設定(エイリアス)
    setBrake = function (self, brake)

        self.locomotive_brake = brake
        self.IR_CONTROL.setBrake(brake)

    end,


    -- ホーンを鳴らす(エイリアス)
    horn = function(self)

        self.IR_CONTROL.horn()
        return true

    end,


    -- 機関車とコンピュータをリンクさせる
    init = function (self)
        print('機関車とリンクしました.')
        self.IR_CONTROL.setThrottle(self.locomotive_throttle)
        self.IR_CONTROL.setBrake(self.locomotive_brake)
        self.last_position = self:getPos()
        self.last_sampling_time = self.COMPUTER.uptime()

    end,
}