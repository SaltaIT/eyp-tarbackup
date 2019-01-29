class { 'tarbackup': }

tarbackup::instance { 'backup':
  includedir  => [ '/etc/logstash', '/etc/elasticsearch', '/etc/kibana' ],
  xdev        => true,
  destination => '/var/backup/tarbackup',
  mailto      => 'demo@demo.com'
}
