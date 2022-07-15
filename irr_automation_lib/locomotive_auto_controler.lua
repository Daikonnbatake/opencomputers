event = require('event')
require('locomotive_controler')

-- 自動操縦クラス. インスタンス化不可.
LocomotiveAutoControler =
{
    -- 自動操縦イベントのID
    auto_control_event_id = 0,

    -- 目標時速(整数)
    target_speed = 0,

    -- 後退フラグ
    back = false,


    -- 自動速度制御
    auto_speed_control = function (self)

        local target_speed = self.target_speed
        local current_speed = LocomotiveControler:getSpeed()
        local speed_diff = current_speed - target_speed

        -- 停止
        if 5 > target_speed then
            LocomotiveControler:setBrake(1)
            LocomotiveControler:setThrottle(0)

        -- 進行
        else
            -- 速度が目標時速より 5km/h 速ければブレーキをかける
            if 5 < speed_diff then
                LocomotiveControler:setThrottle(0)
                LocomotiveControler:addBrake(0.1)

                -- 目標速度より真に速いかつ速すぎないなら惰性運転
            elseif 0 < speed_diff then
                LocomotiveControler:setThrottle(0)
                LocomotiveControler:setBrake(0)

                -- 速度が目標時速より遅ければスロットルを上げる
            else
                if self.back then
                    LocomotiveControler:addThrottle(-0.1)
                else
                    LocomotiveControler:addThrottle(0.1)
                end
                LocomotiveControler:setBrake(0)

            end
        end
    end,

    -- 自動操縦の再帰
    auto_control = function (self)
        return event.timer(0.1, function ()
            self:auto_speed_control()
            self.auto_control_event_id = self:auto_control()

        end)
    end,

    -- 自動操縦開始
    start = function (self)
        self.auto_control_event_id = self:auto_control()

    end,

    -- 自動操縦中断
    stop = function (self)
        event.cancel(self.auto_control_event_id)

    end,
}