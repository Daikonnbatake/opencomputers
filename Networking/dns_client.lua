event = require('event')
computer = require('computer')
component = require('component')


DNSClient =
{
    -- DNS サーバーのアドレス
    DNS_server_address = nil,

    -- DNS サーバーのポート
    DNS_server_port = 53,

    -- 信号強度
    connect_power = 100,

    getName = function (self, name)

        if self.DNS_server_address == nil then
            print('DNSサーバーのアドレスが設定されていません.')
            print('DNS_server_address フィールドに代入して設定してください.')
            return
        end

        component.modem.open(self.DNS_server_port)
        component.modem.setStrength(self.connect_power)

        local address = self.DNS_server_address
        component.modem.send(address, self.DNS_server_port, name)
        local _, _, _, _, _, address = event.pull(1, "modem_message")

        component.modem.close(self.DNS_server_port)

        return address

    end,
}