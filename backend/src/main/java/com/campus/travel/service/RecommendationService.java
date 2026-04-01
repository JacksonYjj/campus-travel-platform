package com.campus.travel.service;

import com.campus.travel.entity.CarpoolTrip;
import com.campus.travel.entity.GroupTrip;
import com.campus.travel.mapper.CarpoolTripMapper;
import com.campus.travel.mapper.GroupTripMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class RecommendationService {
    @Autowired private CarpoolTripMapper carpoolMapper;
    @Autowired private GroupTripMapper groupMapper;

    /**
     * 根据车主的拼车路线推荐相关的主题团
     */
    public List<GroupTrip> recommendGroupsByCarpool(Long carpoolTripId) {
        // 简化逻辑：返回相同目的地的招募中团
        // 实际毕设中可以加入更复杂的逻辑，如时间匹配或标签匹配
        List<GroupTrip> all = groupMapper.findAllRecruitingTrips();
        return all.stream().limit(3).collect(Collectors.toList());
    }

    /**
     * 针对某个约团用户推荐拼车行程
     */
    public List<CarpoolTrip> recommendCarpoolsByGroup(Long groupTripId) {
        List<CarpoolTrip> all = carpoolMapper.findAllOpenTrips();
        return all.stream().limit(3).collect(Collectors.toList());
    }
}
