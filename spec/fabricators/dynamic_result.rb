Fabricator(:dynamic_result) do
  rtt                  1.5
  throughput_udp_down  1.5
  throughput_udp_up    1.5
  throughput_tcp_down  1.5
  throughput_udp_up    1.5
  throughput_http_down 1.5
  throughput_http_up   1.5
  jitter_down          1.5
  jitter_up            1.5
  loss_down            1.5
  loss_up              1.5
  pom_down             ""
  pom_up               ""
  uuid                 "MyString"
end
