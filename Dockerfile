FROM roslab/roslab:kinetic-nvidia

USER root

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    sudo \
    python-wstool \
    python-rosdep \
    ninja-build \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${HOME}/catkin_ws/

ENV ROS_DISTRO kinetic

RUN cd ${HOME}/catkin_ws \
 && wstool init src \
 && wstool merge -t src https://raw.githubusercontent.com/googlecartographer/cartographer_ros/master/cartographer_ros.rosinstall \
 && wstool update -t src \
 && src/cartographer/scripts/install_proto3.sh \
 && apt-get update \
 && /bin/bash -c "source /opt/ros/kinetic/setup.bash && rosdep update && rosdep install --as-root apt:false --from-paths src --ignore-src -r --rosdistro=${ROS_DISTRO} -y" \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && /bin/bash -c "source /opt/ros/kinetic/setup.bash && catkin_make_isolated --install --use-ninja"

RUN echo "source ~/catkin_ws/devel/setup.bash" >> ${HOME}/.bashrc

COPY README.ipynb .

RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}
WORKDIR ${HOME}
