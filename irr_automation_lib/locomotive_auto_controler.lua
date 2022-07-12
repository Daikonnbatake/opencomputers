require('locomotive_controler')

-- 自動操縦クラス. インスタンス化不可.
LocomotiveAutoControler =
{
    -- os API
    OS = require('os'),

    -- computer API
    COMPUTER = require('computer'),

    -- thread API
    THREAD = require('thread'),

    -- 機関車操縦クラス
    LOCOMOTIVE_CONTROLER = LocomotiveControler,

    -- 自動操縦スレッドのスレッドハンドル
    thread_handle = nil,

    -- 目標時速(number)
    target_speed = 0,


    -- 自動操縦スレッド
    auto_control_thread = function (self)

        print('自動操縦を開始')
        print('--- 情報 ---')
        for k, v in pairs(self.LOCOMOTIVE_CONTROLER) do print(k, v) end
        print('------------')

        self.LOCOMOTIVE_CONTROLER:init()

        -- 最終更新時間をメモする
        local last_update = 0

        while true do

            -- もし前回の更新から 0.05 秒以上経過していたなら制御を行う
            if 0.05 < self.COMPUTER.uptime() - last_update then

                local target_speed = self.target_speed
                local current_speed = self.LOCOMOTIVE_CONTROLER:getSpeed()

                if current_speed < target_speed then

                    self.LOCOMOTIVE_CONTROLER:setBrake(0)
                    self.LOCOMOTIVE_CONTROLER:addThrottle(0.3)

                else

                    self.LOCOMOTIVE_CONTROLER:setThrottle(0)
                    self.LOCOMOTIVE_CONTROLER:addBrake(0.3)

                end

                last_update = self.COMPUTER.uptime()

            end

            self.OS.sleep(0.01)

        end

    end,


    -- 自動操縦開始
    start_auto_control = function (self)

        self.thread_handle = self.THREAD.create(self.auto_control_thread, self)

    end,


    -- 自動操縦中断
    stop_auto_control = function (self)

        self.thread_handle.suspend()

    end,
}