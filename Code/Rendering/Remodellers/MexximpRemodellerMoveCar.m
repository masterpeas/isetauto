function [scene, mappings ] = MexximpRemodellerMoveCar(scene, mappings, names, conditionValues, ~ )
% Reads the conditions file, interprets parameters, applies them to the scene
%
% Transformations are applied to the scene
% Nothing seems to happen to mappings.  Not sure why it is here.
% There was a conditionNumber parameter that wasn't used and I deleted.
%
% HB, SCIEN Team, 2017

%% Read certain columns in the conditions file and interpret them

shadowDirection = eval(rtbGetNamedValue(names,conditionValues,'shadowDirection',[]));
cameraPosition  = eval(rtbGetNamedValue(names,conditionValues,'cameraPosition',[]));
cameraLookAt    = eval(rtbGetNamedValue(names,conditionValues,'cameraLookAt',[]));

cameraPan = rtbGetNamedNumericValue(names,conditionValues,'cameraPan',0);
cameraTilt = rtbGetNamedNumericValue(names,conditionValues,'cameraTilt',0);
cameraRoll = rtbGetNamedNumericValue(names,conditionValues,'cameraRoll',0);

carPosition = eval(rtbGetNamedValue(names,conditionValues,'carPosition',[]));
carOrientation = eval(rtbGetNamedValue(names,conditionValues,'carOrientation',[]));

%% Use the parameters to add a camera

scene = mexximpCentralizeCamera(scene);
lookUp = [0 0 -1];
cameraLookDir = cameraLookAt - cameraPosition;

transformation = mexximpLookAt(1000*cameraPosition,1000*cameraLookAt,lookUp);
ptrTransform   = mexximpPTR(deg2rad(cameraPan), deg2rad(cameraTilt), ...
    deg2rad(cameraRoll), cameraLookDir, lookUp);

cameraId = strcmp({scene.rootNode.children.name},'Camera');
scene.rootNode.children(cameraId).transformation = ...
    transformation ...
    * mexximpTranslate(-1000*cameraPosition) ...
    * ptrTransform ...
    * mexximpTranslate(1000*cameraPosition);


%% Translate the car

% Seems to create a transformation of a node in the scene structure.
for i=1:length(scene.rootNode.children)
   if isempty(strfind(scene.rootNode.children(i).name,'Car')) == false
    
       scene.rootNode.children(i).transformation = scene.rootNode.children(i).transformation * ...
           mexximpRotate([0 0 -1],deg2rad(carOrientation))*mexximpTranslate(carPosition*1000);
       
   end
end

%% Add directional light ('SunLight');

% Set the light parameters
ambient = mexximpConstants('light');
ambient.position = [0 0 0]';
ambient.type = 'directional';
ambient.name = 'SunLight';
ambient.lookAtDirection = shadowDirection(:);
ambient.ambientColor = 10000*[1 1 1]';
ambient.diffuseColor = 10000*[1 1 1]';
ambient.specularColor = 10000*[1 1 1]';
ambient.constantAttenuation = 1;
ambient.linearAttenuation = 0;
ambient.quadraticAttenuation = 1;
ambient.innerConeAngle = 0;
ambient.outerConeAngle = 0;

% Concatenate ambient to the existing scene lights
scene.lights = [scene.lights, ambient];

%% Not sure why this is here

ambientNode = mexximpConstants('node');
ambientNode.name = ambient.name;
ambientNode.transformation = eye(4);

scene.rootNode.children = [scene.rootNode.children, ambientNode];

end

