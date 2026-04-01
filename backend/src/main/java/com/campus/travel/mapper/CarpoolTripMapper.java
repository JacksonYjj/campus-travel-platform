package com.campus.travel.mapper;

import com.campus.travel.entity.CarpoolTrip;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface CarpoolTripMapper {
    @Select("SELECT t.*, u.real_name as driver_name FROM carpool_trip t " +
            "JOIN user_account u ON t.driver_user_id = u.id " +
            "WHERE t.trip_status = 'open' ORDER BY t.departure_time ASC")
    List<CarpoolTrip> findAllOpenTrips();

    @Insert("INSERT INTO carpool_trip (trip_no, driver_user_id, vehicle_id, start_location, end_location, departure_time, seat_total, seat_available, pricing_mode, price_per_person, trip_status) " +
            "VALUES (#{tripNo}, #{driverUserId}, #{vehicleId}, #{startLocation}, #{endLocation}, #{departureTime}, #{seatTotal}, #{seatAvailable}, #{pricingMode}, #{pricePerPerson}, 'open')")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(CarpoolTrip trip);

    @Update("UPDATE carpool_trip SET seat_available = seat_available - #{count} WHERE id = #{id} AND seat_available >= #{count}")
    int bookSeats(@Param("id") Long id, @Param("count") Integer count);
}
