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
    connect_power = 100000,

    getDNSServerAddress = function (self)
        component.modem.open(self.DNS_server_port)
        component.modem.broadcast(54)
        local _, _, _, _, _, address = event.pull(1, "modem_message")
        self.DNS_server_address = address
        component.modem.close(self.DNS_server_port)
    end,

    getName = function (self, name)

        if self.DNS_server_address == nil then self:getDNSServerAddress() end

        if self.DNS_server_address == nil then
            print('DNS サービスが応答しませんでした.')
            print('"dns-server" を任意のコンピュータで起動してください.')
            return
        end

        component.modem.open(self.DNS_server_port)
        component.modem.setStrength(self.connect_power)

        local address = self.DNS_server_address
        component.modem.send(address, self.DNS_server_port, name)
        local _, _, _, _, _, address = event.pull(1, "modem_message")

        component.modem.close(self.DNS_server_port)

        if address == nil then
            print('DNS サービスが応答しませんでした.')
            print('1) "dns-server" を任意のコンピュータで起動してください.')
            print('2) DNS サーバーに DNS 情報を設定してください.')
            return
        end

        return address

    end,
}