print("setup-path initialization")
ENV_CTW_ADMIN_PASSWORD="CTW_ADMIN_PASSWORD"

if(os.getenv(ENV_CTW_ADMIN_PASSWORD ~= nil)) then
  minetest.set_player_password("player1",minetest.get_password_hash("player1","playon1"))
  minetest.set_player_password("admin",minetest.get_password_hash("admin",os.getenv(ENV_CTW_ADMIN_PASSWORD)))
  print("setup-path initialized !")
else
  print("Authentication not initialized, please define "..ENV_CTW_ADMIN_PASSWORD.." !!")
end

