function [allData, scenario, sensor] = initialIntersectionTest()
%initialIntersectionTest - Returns sensor detections
%    allData = initialIntersectionTest returns sensor detections in a structure
%    with time for an internally defined scenario and sensor suite.
%
%    [allData, scenario, sensors] = initialIntersectionTest optionally returns
%    the drivingScenario and detection generator objects.

% Generated by MATLAB(R) 9.14 (R2023a) and Automated Driving Toolbox 3.7 (R2023a).
% Generated on: 20-Jun-2023 08:33:12

% Create the drivingScenario object and ego car
[scenario, egoVehicle] = createDrivingScenario;

% Create all the sensors
sensor = createSensor(scenario);

allData = struct('Time', {}, 'ActorPoses', {}, 'ObjectDetections', {}, 'LaneDetections', {}, 'PointClouds', {}, 'INSMeasurements', {});
running = true;
while running

    % Generate the target poses of all actors relative to the ego vehicle
    poses = targetPoses(egoVehicle);
    time  = scenario.SimulationTime;

    % Generate detections for the sensor
    laneDetections = [];
    ptClouds = [];
    insMeas = [];
    [objectDetections, isValidTime] = sensor(poses, time);
    numObjects = length(objectDetections);
    objectDetections = objectDetections(1:numObjects);

    % Aggregate all detections into a structure for later use
    if isValidTime
        allData(end + 1) = struct( ...
            'Time',       scenario.SimulationTime, ...
            'ActorPoses', actorPoses(scenario), ...
            'ObjectDetections', {objectDetections}, ...
            'LaneDetections', {laneDetections}, ...
            'PointClouds',   {ptClouds}, ... %#ok<AGROW>
            'INSMeasurements',   {insMeas}); %#ok<AGROW>
    end

    % Advance the scenario one time step and exit the loop if the scenario is complete
    running = advance(scenario);
end

% Restart the driving scenario to return the actors to their initial positions.
restart(scenario);

% Release the sensor object so it can be used again.
release(sensor);

%%%%%%%%%%%%%%%%%%%%
% Helper functions %
%%%%%%%%%%%%%%%%%%%%

% Units used in createSensors and createDrivingScenario
% Distance/Position - meters
% Speed             - meters/second
% Angles            - degrees
% RCS Pattern       - dBsm

function sensor = createSensor(scenario)
% createSensors Returns all sensor objects to generate detections

% Assign into each sensor the physical and radar profiles for all actors
profiles = actorProfiles(scenario);
sensor = visionDetectionGenerator('SensorIndex', 1, ...
    'UpdateInterval', 0.3, ...
    'SensorLocation', [1.9 0], ...
    'DetectorOutput', 'Objects only', ...
    'Intrinsics', cameraIntrinsics([800 800],[320 240],[480 640]), ...
    'ActorProfiles', profiles);

function [scenario, egoVehicle] = createDrivingScenario
% createDrivingScenario Returns the drivingScenario defined in the Designer

% Construct a drivingScenario object.
scenario = ia_drivingScenario;

% Add all road segments
roadCenters = [-119.91220007542 0.28026685394776 0;
    -82.799082818993 -0.8927607107007 0;
    -36.191496881598 -0.19233884199439 0;
    -33.006654412737 0.0042563675231151 0;
    9.6638580024963 0.8130901598853 0;
    37.384414111568 0.15476839718488 0;
    56.296640453451 0.063362891127205 0;
    83.395183268286 0.44487676825404 0;
    108.29658210418 0.17515715843639 0;
    139.47745915091 -0.93972185438385 0];
headings = [-1.81033463389367;-1.81033463389367;3.53229450127628;3.53229450127628;-1.36043338158969;-1.36043338158969;0.806600231691492;0.806600231691492;-2.0477506654296;-2.0477506654296];
marking = [laneMarking('Solid', 'Width', 3)
    laneMarking('Solid', 'Width', 0.125)
    laneMarking('Dashed', 'Width', 0.125)
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Dashed', 'Width', 0.125)
    laneMarking('Solid', 'Width', 0.125)
    laneMarking('Solid', 'Width', 3)];
lanetypes = [laneType('Shoulder')
    laneType('Driving')
    laneType('Driving')
    laneType('Driving')
    laneType('Driving')
    laneType('Shoulder')];
laneSpecification = lanespec([3 3], 'Width', [1.34825724463726 3.5 3.5 3.5 3.5 1.48779317020945], 'Marking', marking, 'Type', lanetypes);
road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_i01');

% Add the barriers
barrierCenters = [50.9 -30.9 0;
    -53.5 -79.4 0;
    -80.4 -93.3 0;
    50.7 -90 0;
    50.9 -30.9 0];
barrier(scenario, barrierCenters, ...
    'ClassID', 5, ...
    'Width', 0.61, ...
    'Height', 0.81, ...
    'Mesh', driving.scenario.jerseyBarrierMesh, 'PlotColor', [0.65 0.65 0.65], 'Name', 'grass_001');

% Add the ego vehicle
egoVehicle = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [-33.3312470364824 -4.08525415743442 0], ...
    'Mesh', driving.scenario.carMesh, ...
    'Name', 'car_058');
waypoints = [-33.3312470364824 -4.08525415743442 0;
    1.5 -3.2 0;
    34.1 -3 0;
    74.9 -2.7 0;
    110.5 -2.7 0];
speed = [30;30;30;30;30];
trajectory(egoVehicle, waypoints, speed);

% Add the non-ego actors
truck_001 = vehicle(scenario, ...
    'ClassID', 2, ...
    'Length', 8.2, ...
    'Width', 2.5, ...
    'Height', 3.5, ...
    'Position', [124.2 2.5 0], ...
    'Mesh', driving.scenario.truckMesh, ...
    'Name', 'truck_001');
waypoints = [124.2 2.5 0;
    104.2 2.8 0;
    77.5 2.3 0;
    43.8 2.8 0;
    19.6 3.4 0;
    -7.7 3.6 0;
    -34.4 3.4 0];
speed = [30;30;30;30;30;30;30];
trajectory(truck_001, waypoints, speed);

pedestrian_001 = actor(scenario, ...
    'ClassID', 4, ...
    'Length', 0.24, ...
    'Width', 0.45, ...
    'Height', 1.7, ...
    'Position', [34.5426598994153 -9.55984235884758 0], ...
    'RCSPattern', [-8 -8;-8 -8], ...
    'Mesh', driving.scenario.pedestrianMesh, ...
    'Name', 'pedestrian_001');
waypoints = [34.5426598994153 -9.55984235884758 0;
    35.2 29.2 0];
speed = [1.5;1.5];
trajectory(pedestrian_001, waypoints, speed);

vehicle(scenario, ...
    'ClassID', 2, ...
    'Length', 8.2, ...
    'Width', 2.5, ...
    'Height', 3.5, ...
    'Position', [46.3 -18.6 0], ...
    'Yaw', 90, ...
    'Mesh', driving.scenario.truckMesh, ...
    'Name', 'bus_001');

actor(scenario, ...
    'ClassID', 4, ...
    'Length', 0.24, ...
    'Width', 0.45, ...
    'Height', 1.7, ...
    'Position', [48 15.1 0], ...
    'RCSPattern', [-8 -8;-8 -8], ...
    'Mesh', driving.scenario.pedestrianMesh, ...
    'Name', 'deer_001');

