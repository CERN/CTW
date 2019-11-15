docker run -d --restart=always --name CERN_v1 -p 30001:30000/udp -v /home/minetest/.minetest/worlds:/minetest/worlds \
         -v /home/minetest/.minetest/minetest.conf:/minetest/minetest.conf \
         webd97/minetestserver:5.0.1 --world /minetest/worlds/CERN_v1 --config /minetest/minetest.conf
