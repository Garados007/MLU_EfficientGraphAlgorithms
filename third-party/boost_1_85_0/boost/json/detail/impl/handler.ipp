//
// Copyright (c) 2019 Vinnie Falco (vinnie.falco@gmail.com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//
// Official repository: https://github.com/boostorg/json
//

#ifndef BOOST_JSON_DETAIL_IMPL_HANDLER_HPP
#define BOOST_JSON_DETAIL_IMPL_HANDLER_HPP

#include <boost/json/detail/handler.hpp>
#include <utility>

namespace boost {
namespace json {
namespace detail {

template<class... Args>
handler::
handler(Args&&... args)
    : st(std::forward<Args>(args)...)
{
}

bool
handler::
on_document_begin(
    system::error_code&)
{
    return true;
}

bool
handler::
on_document_end(
    system::error_code&)
{
    return true;
}

bool
handler::
on_object_begin(
    system::error_code&)
{
    return true;
}

bool
handler::
on_object_end(
    std::size_t n,
    system::error_code&)
{
    st.push_object(n);
    return true;
}

bool
handler::
on_array_begin(
    system::error_code&)
{
    return true;
}

bool
handler::
on_array_end(
    std::size_t n,
    system::error_code&)
{
    st.push_array(n);
    return true;
}

bool
handler::
on_key_part(
    string_view s,
    std::size_t,
    system::error_code&)
{
    st.push_chars(s);
    return true;
}

bool
handler::
on_key(
    string_view s,
    std::size_t,
    system::error_code&)
{
    st.push_key(s);
    return true;
}

bool
handler::
on_string_part(
    string_view s,
    std::size_t,
    system::error_code&)
{
    st.push_chars(s);
    return true;
}

bool
handler::
on_string(
    string_view s,
    std::size_t,
    system::error_code&)
{
    st.push_string(s);
    return true;
}

bool
handler::
on_number_part(
    string_view,
    system::error_code&)
{
    return true;
}

bool
handler::
on_int64(
    std::int64_t i,
    string_view,
    system::error_code&)
{
    st.push_int64(i);
    return true;
}

bool
handler::
on_uint64(
    std::uint64_t u,
    string_view,
    system::error_code&)
{
    st.push_uint64(u);
    return true;
}

bool
handler::
on_double(
    double d,
    string_view,
    system::error_code&)
{
    st.push_double(d);
    return true;
}

bool
handler::
on_bool(
    bool b,
    system::error_code&)
{
    st.push_bool(b);
    return true;
}

bool
handler::
on_null(system::error_code&)
{
    st.push_null();
    return true;
}

bool
handler::
on_comment_part(
    string_view,
    system::error_code&)
{
    return true;
}

bool
handler::
on_comment(
    string_view, system::error_code&)
{
    return true;
}

} // detail
} // namespace json
} // namespace boost

#endif
