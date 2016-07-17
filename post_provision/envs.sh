function get_role() {
  ip=$(hostname -i)
  role=$(fleetctl list-machines | grep -w $ip | grep -Eo 'role=(.*)')
  role=${role/role=/}
}
