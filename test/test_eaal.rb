require File.dirname(__FILE__) + '/test_helper.rb'

class TestEaal < Test::Unit::TestCase

  # prepare the api object. sets EAAL to use FileCache to load fixtures
  def setup
    EAAL.cache = EAAL::Cache::FileCache.new(File.dirname(__FILE__) + '/fixtures/')
    @api = EAAL::API.new('test','test')
  end

  # test if we really got an API Object
  def test_api_class
    assert_instance_of EAAL::API, @api
  end

  # some random tests if parsing the xml builds the right class
  def test_api_classes
    @api.scope = "char"
    assert_raise EAAL::Exception.EveAPIException(105) do @api.Killlog end
    assert_equal @api.Killlog(:characterID => 12345).class.name, "CharKilllogResult"
    assert_equal @api.Killlog(:characterID => 12345).kills.class.name, "CharKilllogRowsetKills"
    assert_equal @api.Killlog(:characterID => 12345).kills.first.class.name, "CharKilllogRowsetKillsRow"
    assert_equal @api.Killlog(:characterID => 12345).kills.first.victim.class.name, "EAAL::Result::ResultElement"
    assert_equal @api.Killlog(:characterID => 12345).kills.first.attackers.first.class.name, "CharKilllogRowsetKillsRowRowsetAttackersRow"
  end

  # some random data checks to ensure stuff can be read
  def test_api_parse_data
    @api.scope = "account"
    assert_equal @api.Characters.characters.first.name, "Test Tester"
    assert_equal @api.Characters.characters.second.corporationID, "7890"
    @api.scope = "char"
    assert_equal @api.Killlog(:characterID => 12345).kills.length, 1
    assert_equal @api.Killlog(:characterID => 12345).kills.first.victim.characterName, "Peter Powers"
    assert_equal @api.Killlog(:characterID => 12345).kills.first.attackers.first.characterID, "12345"
    assert_equal @api.SkillInTraining(:characterID => 12345).skillInTraining, "1"
    assert_equal @api.SkillInTraining(:characterID => 12345).trainingDestinationSP, "135765"
    assert_equal @api.CharacterSheet(:characterID => 12345).attributes.willpower, "10"
    assert_equal @api.CharacterSheet(:characterID => 12345).gender, "Female"
    assert_equal @api.CharacterSheet(:characterID => 12345).corporationRoles[0].roleName, "roleDirector"
    assert_equal @api.CharacterSheet(:characterID => 12345).skills[4].typeID, "3445"
    assert_nil @api.CharacterSheet(:characterID => 12345).skills[4].level
    # test unpublished skill (like Black Market, not sure it exists now)
    assert_equal @api.CharacterSheet(:characterID => 12345).skills[4].unpublished, "1"
    assert_equal @api.SkillQueue(:characterID => 12345).skillqueue[0].level, "3"
  end

  def test_server_status
    @api.scope = "server"
    assert_not_nil @api.ServerStatus
    assert_not_nil @api.ServerStatus.onlinePlayers
  end

  # test to check if bug 23177 is fixed. that bug lead to RowSets beeing encapsulated in ResultElements.
  def test_bug_23177
   @api.scope = "eve"
   assert_kind_of EAAL::Rowset::RowsetBase, @api.AllianceList.alliances.first.memberCorporations
  end

  # test for Standings.xml
  def test_standings
    @api.scope = "account"
    id = @api.Characters.characters.first.characterID
    @api.scope = "char"
    assert_equal @api.Standings(:characterID => 12345).standingsTo.characters[0].toName, "Test Ally"
    assert_equal @api.Standings(:characterID => 12345).standingsTo.characters[0].standing, "1"
    assert_equal @api.Standings(:characterID => 12345).standingsFrom.NPCCorporations[1].fromName, "Carthum Conglomerate"
  end

  # test for CorporationSheet
  def test_corporation
    @api.scope = "corp"
    assert_equal @api.CorporationSheet(:corporationID => 150212025).corporationID, "150212025"
    assert_equal @api.CorporationSheet(:corporationID => 150212025).ceoName, "Mark Roled"
    assert_equal @api.CorporationSheet(:corporationID => 150212025).walletDivisions[0].description, "Master Wallet"
  end

  # Test to ensure Memcached works
  def test_memcached
    # FIXME must check if memcache server is installed... (binary memcache)
    # Note if I run memcached I get a new error: EAAL::Exception::APINotFoundError: The requested API (account / Chracters) could not be found.
    # this beacuse eaal request to EVE api the Test Tester PG....
    # TODO: API needs mocking properly instead of depending on file cache for test loading.

    EAAL.cache = EAAL::Cache::MemcachedCache.new

    assert_instance_of EAAL::Cache::MemcachedCache, EAAL.cache

    # loading an XML from fixtures
    file = 'test/fixtures/test/test/account/Characters/Request_.xml'
    xml = ''
    File.open(file, File::RDONLY).each { |line| xml += line }

    @api.scope = 'account'

    # store to cache
    assert_equal EAAL.cache.save(@api.userid,@api.key,@api.scope,'Characters','',xml), "STORED\r\n"

    # check key in cache
    assert_equal EAAL.cache.key(@api.userid,@api.key,@api.scope,'Characters',''), "testtestaccountCharacters"

    # load from cache
    assert_equal EAAL.cache.load(@api.userid,@api.key,@api.scope,'Characters',''), xml

    # FIXME high level tests
    # Should store to cache
    #assert_equal @api.Characters.characters.first.name, "Test Tester"
    # Should get from cache
    #assert_equal @api.Characters.characters.first.name, "Test Tester"
    # TODO: Needs some better tests here.
  end

end
