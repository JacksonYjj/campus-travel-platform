package com.campus.travel.mapper;

import com.campus.travel.entity.GroupTrip;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface GroupTripMapper {
    @Select("SELECT g.*, u.real_name as creator_name FROM group_trip g " +
            "JOIN user_account u ON g.creator_user_id = u.id " +
            "WHERE g.group_status = 'recruiting' ORDER BY g.start_time ASC")
    List<GroupTrip> findAllRecruitingTrips();

    @Insert("INSERT INTO group_trip (group_no, creator_user_id, title, trip_category, gather_location, destination, start_time, signup_deadline, max_member_count, budget_per_person, group_status) " +
            "VALUES (#{groupNo}, #{creatorUserId}, #{title}, #{tripCategory}, #{gatherLocation}, #{destination}, #{startTime}, #{signupDeadline}, #{maxMemberCount}, #{budgetPerPerson}, 'recruiting')")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(GroupTrip trip);

    @Update("UPDATE group_trip SET current_member_count = current_member_count + #{count} WHERE id = #{id} AND current_member_count + #{count} <= max_member_count")
    int incrementMemberCount(@Param("id") Long id, @Param("count") Integer count);
}
