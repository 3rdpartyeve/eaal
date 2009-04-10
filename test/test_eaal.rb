require File.dirname(__FILE__) + '/test_helper.rb'

class TestEaal < Test::Unit::TestCase
 
  # prepare the api object. sets EAAL to use FileCache to load fixtures 
  def setup
    EAAL.cache = EAAL::Cache::FileCache.new(File.dirname(__FILE__) + '/fixtures/')
    @api = EAAL::API.new('test','test')
  end
  # test if we realy got an API Object
  def test_api_class
    assert_instance_of EAAL::API, @api
  end

  # some random tests if parsing the xml builds the right class
  def test_api_classes
    @api.scope = "char"  
    assert_raise (EAAL::Exception.EveAPIException(105)) { @api.Killlog }
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
  end

  # test to check if bug 23177 is fixed. that bug lead to RowSets beeing encapsulated in ResultElements.
  def test_bug_23177
   @api.scope = "eve"
   assert_kind_of EAAL::Rowset::RowsetBase, @api.AllianceList.alliances.first.memberCorporations
  end
  # Test to ensure Memcached works
  def test_memcached
    # TODO: API needs mocking properly instead of depending on file cache for test loading.
    EAAL.cache = EAAL::Cache::MemcachedCache.new
    @api.scope = "account"
    # Should store to cache
    assert_equal @api.Characters.characters.first.name, "Test Tester"
    # Should get from cache
    assert_equal @api.Characters.characters.first.name, "Test Tester"
    # TODO: Needs some better tests here.
  end
end
