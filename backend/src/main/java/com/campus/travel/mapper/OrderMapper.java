package com.campus.travel.mapper;

import org.apache.ibatis.annotations.*;
import java.util.List;
import java.util.Map;

@Mapper
public interface OrderMapper {
    @Select("SELECT o.id, o.order_no as orderNo, CONCAT('拼车：', t.start_location, ' -> ', t.end_location) as title, " +
            "o.total_amount as amount, UPPER(o.order_status) as status, o.created_at as createTime " +
            "FROM carpool_order o " +
            "JOIN carpool_trip t ON o.trip_id = t.id " +
            "WHERE o.passenger_user_id = #{userId} " +
            "ORDER BY o.created_at DESC")
    List<Map<String, Object>> findCarpoolOrdersByUserId(@Param("userId") Long userId);

    @Select("SELECT s.id, s.signup_no as orderNo, CONCAT('约团：', g.title) as title, " +
            "s.pay_amount as amount, UPPER(s.signup_status) as status, s.created_at as createTime " +
            "FROM group_signup s " +
            "JOIN group_trip g ON s.group_trip_id = g.id " +
            "WHERE s.user_id = #{userId} " +
            "ORDER BY s.created_at DESC")
    List<Map<String, Object>> findGroupOrdersByUserId(@Param("userId") Long userId);

    @Update("UPDATE carpool_order SET order_status = 'cancelled', pay_status = 'failed', canceled_at = NOW() WHERE id = #{orderId} AND passenger_user_id = #{userId}")
    int cancelCarpoolOrder(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Update("UPDATE group_signup SET signup_status = 'cancelled', pay_status = 'failed', canceled_at = NOW() WHERE id = #{orderId} AND user_id = #{userId}")
    int cancelGroupOrder(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Insert("INSERT INTO carpool_order (order_no, trip_id, passenger_user_id, passenger_count, total_amount, order_status, created_at, updated_at) " +
            "VALUES (#{orderNo}, #{tripId}, #{userId}, #{count}, #{amount}, 'pending_confirm', NOW(), NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int createCarpoolOrder(Map<String, Object> params);

    @Insert("INSERT INTO group_signup (signup_no, group_trip_id, user_id, member_count, contact_phone, signup_status, pay_status, pay_amount, created_at, updated_at) " +
            "VALUES (#{orderNo}, #{tripId}, #{userId}, #{count}, #{phone}, 'pending_pay', 'unpaid', #{amount}, NOW(), NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int createGroupOrder(Map<String, Object> params);

    @Select("SELECT o.id, o.order_no as orderNo, CONCAT('拼车：', t.start_location, ' -> ', t.end_location) as title, " +
            "o.total_amount as amount, UPPER(o.order_status) as status, o.created_at as createTime, " +
            "t.start_location, t.end_location, t.departure_time, t.trip_no " +
            "FROM carpool_order o " +
            "JOIN carpool_trip t ON o.trip_id = t.id " +
            "WHERE o.id = #{orderId} AND o.passenger_user_id = #{userId}")
    Map<String, Object> getCarpoolOrderDetails(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Select("SELECT s.id, s.signup_no as orderNo, CONCAT('约团：', g.title) as title, " +
            "s.pay_amount as amount, UPPER(s.signup_status) as status, s.created_at as createTime, " +
            "g.title as trip_title, g.destination, g.start_time as departure_time, g.trip_category as theme " +
            "FROM group_signup s " +
            "JOIN group_trip g ON s.group_trip_id = g.id " +
            "WHERE s.id = #{orderId} AND s.user_id = #{userId}")
    Map<String, Object> getGroupOrderDetails(@Param("orderId") Long orderId, @Param("userId") Long userId);
}
