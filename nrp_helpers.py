import numpy as np
import rospy
import tf
from std_msgs.msg import Bool
from gazebo_msgs.msg import ModelStates


raw_data = {'pose': None, 'action_done': None}


# for the callbacks below you do not need to put in to the nrp tran. funcs.
# get data from rostopic
def get_data(data, args):
    args[0][args[1]] = data


# subscribe to ros topics
def perform_subscribers():
    rospy.Subscriber('/gazebo/model_states', ModelStates, get_data,
                     callback_args=[raw_data, 'pose'])
    rospy.Subscriber('action_done_topic', Bool, get_data,
                     callback_args=[raw_data, 'action_done'])


def get_action_name(action_id):
    return 'Move forward' if action_id == 0 else 'Turn left' \
           if action_id == 1 else 'Turn right' if action_id == 2 else ''


def get_state():
    pose = raw_data['pose']
    pose = pose.pose[pose.name.index('husky')]
    position = np.asarray([pose.position.x, pose.position.y])

    orientation = [pose.orientation.x, pose.orientation.y,
                   pose.orientation.z, pose.orientation.w]
    _, _, yaw = tf.transformations.euler_from_quaternion(orientation)

    return position, yaw if yaw >= 0 else 2 * np.pi + yaw
