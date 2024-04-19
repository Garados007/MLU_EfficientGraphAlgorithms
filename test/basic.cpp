#include <boost/test/unit_test.hpp>
#include <boost/test/debug.hpp>

namespace ega::test::basic
{
class Basic_Fixture
{
  public:
    Basic_Fixture()
    {
        boost::debug::detect_memory_leaks(false);
    }

    ~Basic_Fixture() { }
};

BOOST_FIXTURE_TEST_SUITE(Basic_Tests, Basic_Fixture)

BOOST_AUTO_TEST_CASE(Basic_AllwaySuccess)
{
    BOOST_CHECK(1);
}

BOOST_AUTO_TEST_SUITE_END() // Basic_Tests

} // namespace ega::test::basic
